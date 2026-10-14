import UIKit

/// Analytics sheet. Each row is one tipster and points derived from posted fixtures.
final class StandingsViewController: UITableViewController {
    private let store = BoardSession.shared.store
    private let emptyState = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        Chrome.dressTable(tableView)
        tableView.register(PlatedCell.self, forCellReuseIdentifier: "row")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(close)
        )
        installDone()
        buildEmpty()
        showEmptyIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if emptyState.isHidden == false {
            tableView.bringSubviewToFront(emptyState)
        }
    }

    private func installDone() {
        guard navigationController == nil else { return }
        let button = UIButton(type: .system)
        Chrome.filledCapsule(button, title: "Done")
        button.addAction(UIAction { [weak self] _ in self?.close() }, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 64))
        header.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: Chrome.unit * 2),
            button.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -Chrome.unit * 2),
            button.centerYAnchor.constraint(equalTo: header.centerYAnchor)
        ])
        tableView.tableHeaderView = header
    }

    @objc private func close() {
        dismiss(animated: true)
    }

    private func buildEmpty() {
        emptyState.backgroundColor = DesignTokens.bgColor
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        let card = UIView()
        Chrome.card(card)
        card.translatesAutoresizingMaskIntoConstraints = false
        let art = UIImageView(image: UIImage(named: "grc_EmptyList"))
        art.contentMode = .scaleAspectFit
        art.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(art)
        let headline = UILabel()
        headline.font = TypeScale.copperplate(.title)
        headline.textColor = DesignTokens.inkColor
        headline.numberOfLines = 0
        headline.text = "No scores are posted yet."
        let line = UILabel()
        line.font = TypeScale.editorial(.body)
        line.textColor = DesignTokens.mutedColor
        line.numberOfLines = 0
        line.text = "Seal a cell, then enter the final goals."
        let button = UIButton(type: .system)
        Chrome.filledCapsule(button, title: "Back to the board")
        button.addAction(UIAction { [weak self] _ in self?.close() }, for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [card, headline, line, UIView(), button])
        stack.axis = .vertical
        stack.spacing = Chrome.unit * 2
        stack.setCustomSpacing(Chrome.unit * 3, after: card)
        stack.translatesAutoresizingMaskIntoConstraints = false
        emptyState.addSubview(stack)
        tableView.addSubview(emptyState)
        let frame = tableView.frameLayoutGuide
        let safe = tableView.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            emptyState.leadingAnchor.constraint(equalTo: frame.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: frame.trailingAnchor),
            emptyState.topAnchor.constraint(equalTo: frame.topAnchor),
            emptyState.bottomAnchor.constraint(equalTo: frame.bottomAnchor),
            art.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: Chrome.unit * 2),
            art.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -Chrome.unit * 2),
            art.topAnchor.constraint(equalTo: card.topAnchor, constant: Chrome.unit * 2),
            art.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -Chrome.unit * 2),
            art.heightAnchor.constraint(equalToConstant: 180),
            stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.unit * 2),
            stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.unit * 2),
            stack.topAnchor.constraint(equalTo: safe.topAnchor, constant: Chrome.unit * 3),
            stack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Chrome.unit * 2)
        ])
    }

    private func showEmptyIfNeeded() {
        let vacant = store.standings().isEmpty
        emptyState.isHidden = vacant == false
        if vacant {
            tableView.bringSubviewToFront(emptyState)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 2 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 { return store.loadNotice == nil ? 0 : 1 }
        let rows = store.standings()
        return rows.isEmpty ? 0 : rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if store.standings().isEmpty { return nil }
        return section == 0 ? "Standings" : "Board"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = DesignTokens.inkColor
        cell.textLabel?.font = TypeScale.editorial(.body)
        cell.selectionStyle = .none
        if indexPath.section == 1 {
            cell.textLabel?.text = store.loadNotice
            cell.imageView?.image = nil
            return cell
        }
        let rows = store.standings()
        guard rows.indices.contains(indexPath.row) else {
            cell.textLabel?.text = nil
            return cell
        }
        let standing = rows[indexPath.row]
        let points = CountText.string(standing.points)
        cell.textLabel?.attributedText = TypeScale.editorialLine(
            "\(standing.name) holds \(points) points.",
            numbers: [points]
        )
        return cell
    }
}
