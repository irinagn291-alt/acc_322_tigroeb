import UIKit

/// Tipster names, round reset, onboarding replay, and the contact link.
final class SettingsViewController: UITableViewController, UITextFieldDelegate {
    private let store = BoardSession.shared.store
    private var nameFields: [UUID: UITextField] = [:]
    private let contactURL = URL(string: "https://graticule-lattice.pro/contact-us")!

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
        installDone()
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
        saveNames()
        dismiss(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 5 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return max(store.chart.tipsters.count, 1)
        case 3: return 2
        case 4: return store.loadNotice == nil ? 0 : 1
        default: return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Tipsters"
        case 1: return "Round"
        case 2: return "Onboarding"
        case 3: return "Data"
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
        cell.contentView.subviews.filter { $0 is UITextField }.forEach { $0.removeFromSuperview() }
        if indexPath.section == 4 {
            cell.textLabel?.text = store.loadNotice ?? "The saved board could not be read."
            return cell
        }
        if indexPath.section == 0 {
            if store.chart.tipsters.isEmpty {
                cell.textLabel?.text = "No tipsters are named yet."
                return cell
            }
            let tipster = store.chart.tipsters[indexPath.row]
            cell.textLabel?.text = nil
            let field = nameFields[tipster.id] ?? UITextField()
            field.text = tipster.name
            field.font = TypeScale.editorial(.body)
            field.textColor = DesignTokens.inkColor
            field.delegate = self
            field.accessibilityLabel = "Tipster name"
            field.translatesAutoresizingMaskIntoConstraints = false
            nameFields[tipster.id] = field
            cell.contentView.addSubview(field)
            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: Chrome.unit * 4),
                field.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -Chrome.unit * 4),
                field.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: Chrome.unit * 2),
                field.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -Chrome.unit * 2),
                field.heightAnchor.constraint(greaterThanOrEqualToConstant: Chrome.hit)
            ])
            return cell
        }
        switch indexPath.section {
        case 1:
            cell.textLabel?.text = "Reset this round"
        case 2:
            cell.textLabel?.text = "Replay onboarding"
        default:
            cell.textLabel?.text = indexPath.row == 0
                ? "Contact"
                : "Reset all data"
        }
        cell.selectionStyle = .default
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 1:
            confirm(
                title: "Reset this round?",
                message: "Aimed cells, seals, and posted points on this device are deleted.",
                action: "Reset this round"
            ) { [weak self] in
                self?.store.resetRound()
                self?.tableView.reloadData()
            }
        case 2:
            store.reopenOnboarding()
            dismiss(animated: true)
        case 3:
            if indexPath.row == 0 {
                UIApplication.shared.open(contactURL)
            } else {
                confirm(
                    title: "Reset all data?",
                    message: "Tipsters, fixtures, and marks on this device are deleted.",
                    action: "Reset all data"
                ) { [weak self] in
                    guard let self else { return }
                    Task { @MainActor in
                        await self.store.resetAllData()
                        self.nameFields.removeAll()
                        self.tableView.reloadData()
                    }
                }
            }
        default:
            break
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        saveNames()
    }

    private func saveNames() {
        for tipster in store.chart.tipsters {
            guard let field = nameFields[tipster.id], let text = field.text else { continue }
            _ = store.renameTipster(tipster.id, name: text)
        }
    }

    private func confirm(title: String, message: String, action: String, perform: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: action, style: .destructive) { _ in perform() })
        present(alert, animated: true)
    }
}
