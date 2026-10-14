import UIKit

/// Sheet where a match is typed: home side, away side, and a kickoff daykey.
final class FixturesViewController: UITableViewController {
    private let store = BoardSession.shared.store
    private let homeField = UITextField()
    private let awayField = UITextField()
    private let dayField = UITextField()
    private let notice = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        Chrome.dressTable(tableView)
        tableView.keyboardDismissMode = .interactive
        tableView.register(PlatedCell.self, forCellReuseIdentifier: "row")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(close)
        )
        notice.font = TypeScale.editorial(.body)
        notice.textColor = DesignTokens.inkColor
        notice.numberOfLines = 0
        notice.text = store.loadNotice
        configure(homeField, placeholder: "Home side")
        configure(awayField, placeholder: "Away side")
        Chrome.numberPad(dayField, placeholder: "Kickoff daykey")
        dayField.text = CountText.string(DayKey.adding(days: 7, to: DayKey.today()))
        installDone()
        insertNotice()
        if let text = store.loadNotice {
            showNotice(text)
        }
    }

    /// The failure label lives in the sheet footer so a bad daykey or blank sides stay visible.
    private func insertNotice() {
        notice.translatesAutoresizingMaskIntoConstraints = false
        let host = UIView()
        host.backgroundColor = DesignTokens.surfaceColor
        host.layer.cornerRadius = Chrome.cardRadius
        host.layer.cornerCurve = .continuous
        host.layer.masksToBounds = true
        host.addSubview(notice)
        NSLayoutConstraint.activate([
            notice.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: Chrome.unit * 2),
            notice.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -Chrome.unit * 2),
            notice.topAnchor.constraint(equalTo: host.topAnchor, constant: Chrome.unit * 2),
            notice.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -Chrome.unit * 2)
        ])
        let width = tableView.bounds.width > 0 ? tableView.bounds.width : view.bounds.width
        host.frame = CGRect(x: Chrome.unit * 2, y: 0, width: max(width - Chrome.unit * 4, 0), height: 0)
        host.isHidden = true
        tableView.tableFooterView = host
    }

    private func showNotice(_ text: String) {
        notice.text = text
        guard let host = tableView.tableFooterView else { return }
        host.isHidden = false
        let width = tableView.bounds.width > 0 ? tableView.bounds.width : view.bounds.width
        let cardWidth = max(width - Chrome.unit * 4, 0)
        let labelWidth = max(cardWidth - Chrome.unit * 4, 0)
        let labelHeight = notice.sizeThatFits(CGSize(width: labelWidth, height: .greatestFiniteMagnitude)).height
        host.frame = CGRect(x: Chrome.unit * 2, y: 0, width: cardWidth, height: labelHeight + Chrome.unit * 4)
        tableView.tableFooterView = host
    }

    private func clearNotice() {
        notice.text = nil
        guard let host = tableView.tableFooterView else { return }
        host.isHidden = true
        host.frame.size.height = 0
        tableView.tableFooterView = host
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

    override func numberOfSections(in tableView: UITableView) -> Int { 3 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return store.chart.fixtures.isEmpty ? 1 : store.chart.fixtures.count }
        if section == 1 { return 4 }
        return store.loadNotice == nil ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Matches"
        case 1: return "Add a fixture"
        default: return "Board"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath)
        cell.textLabel?.font = TypeScale.editorial(.body)
        cell.textLabel?.textColor = DesignTokens.inkColor
        cell.textLabel?.numberOfLines = 0
        cell.selectionStyle = .none
        cell.accessoryView = nil
        cell.contentView.subviews.filter { $0 is UITextField || $0 is UIButton }.forEach { $0.removeFromSuperview() }
        if indexPath.section == 2 {
            cell.textLabel?.text = store.loadNotice
            return cell
        }
        if indexPath.section == 0 {
            if store.chart.fixtures.isEmpty {
                cell.textLabel?.text = "No matches are typed yet."
                return cell
            }
            let fixture = store.chart.fixtures[indexPath.row]
            let day = CountText.string(fixture.kickoffDayKey)
            cell.textLabel?.attributedText = TypeScale.editorialLine(
                "\(fixture.title). Kickoff \(day).",
                numbers: [day]
            )
            return cell
        }
        cell.imageView?.image = nil
        cell.textLabel?.text = nil
        if indexPath.row == 3 {
            let button = UIButton(type: .system)
            Chrome.filledCapsule(button, title: "Add a fixture")
            button.addAction(UIAction { [weak self] _ in self?.addFixture() }, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(button)
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Chrome.unit * 4),
                button.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -Chrome.unit * 4),
                button.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Chrome.unit * 2),
                button.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Chrome.unit * 2)
            ])
            return cell
        }
        let field = [homeField, awayField, dayField][indexPath.row]
        field.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(field)
        NSLayoutConstraint.activate([
            field.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Chrome.unit * 4),
            field.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -Chrome.unit * 4),
            field.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Chrome.unit * 2),
            field.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Chrome.unit * 2)
        ])
        return cell
    }

    private func addFixture() {
        let home = homeField.text ?? ""
        let away = awayField.text ?? ""
        guard let day = Int(dayField.text ?? ""), DayKey.isCalendarDay(day) else {
            showNotice("Enter the kickoff as a daykey, such as a year month and day.")
            return
        }
        let outcome = store.addFixture(homeSide: home, awaySide: away, kickoffDayKey: day)
        if let refusal = outcome.refusal {
            let text = refusal == .emptyName
                ? "Enter both side names before adding the fixture."
                : refusal.sentence
            showNotice(text)
            return
        }
        clearNotice()
        homeField.text = nil
        awayField.text = nil
        tableView.reloadData()
    }

    private func configure(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.font = TypeScale.editorial(.body)
        field.textColor = DesignTokens.inkColor
        field.accessibilityLabel = placeholder
        field.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
    }
}
