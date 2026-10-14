import UIKit

/// Six type steps. Copperplate for lattice numerals and short titles.
/// Long lines use New York so Copperplate does not clip.
enum TypeScale {
    enum Step {
        case display
        case title
        case headline
        case body
        case caption
        case micro

        var pointSize: CGFloat {
            switch self {
            case .display: return 28
            case .title: return 22
            case .headline: return 18
            case .body: return 16
            case .caption: return 14
            case .micro: return 12
            }
        }

        var textStyle: UIFont.TextStyle {
            switch self {
            case .display: return .title2
            case .title: return .title3
            case .headline: return .headline
            case .body: return .body
            case .caption: return .caption1
            case .micro: return .caption2
            }
        }
    }

    /// Copperplate-Bold stays at or under 34pt. Above accessibility-1, New York carries the line.
    static func copperplate(_ step: Step, compatibleWith traits: UITraitCollection? = nil) -> UIFont {
        let category = traits?.preferredContentSizeCategory ?? UITraitCollection.current.preferredContentSizeCategory
        if needsNewYork(category) {
            return editorial(step, compatibleWith: traits)
        }
        let size = min(step.pointSize, 34)
        let named = UIFont(name: "Copperplate-Bold", size: size)
            ?? UIFont(name: DesignTokens.fontFamily, size: size)
            ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        let scaled = UIFontMetrics(forTextStyle: step.textStyle).scaledFont(for: named, compatibleWith: traits)
        guard scaled.pointSize > 34 else { return scaled }
        return UIFont(descriptor: scaled.fontDescriptor, size: 34)
    }

    /// New York (serif design) for sentences and for Copperplate once type is past accessibility-1.
    static func editorial(_ step: Step, compatibleWith traits: UITraitCollection? = nil) -> UIFont {
        let base = UIFont.systemFont(ofSize: step.pointSize)
        let descriptor = base.fontDescriptor.withDesign(.serif) ?? base.fontDescriptor
        let font = UIFont(descriptor: descriptor, size: step.pointSize)
        return UIFontMetrics(forTextStyle: step.textStyle).scaledFont(for: font, compatibleWith: traits)
    }

    /// Monospaced digits for points, goal counts, and day labels.
    static func digits(_ step: Step, compatibleWith traits: UITraitCollection? = nil) -> UIFont {
        let base = UIFont.monospacedDigitSystemFont(ofSize: step.pointSize, weight: .semibold)
        return UIFontMetrics(forTextStyle: step.textStyle).scaledFont(for: base, compatibleWith: traits)
    }

    static func digitLine(_ text: String, step: Step, color: UIColor = DesignTokens.inkColor) -> NSAttributedString {
        NSAttributedString(
            string: text,
            attributes: [
                .font: digits(step),
                .foregroundColor: color
            ]
        )
    }

    /// Editorial sentence with monospaced digits on the numeric tokens.
    static func editorialLine(_ text: String, step: Step = .body, numbers: [String] = []) -> NSAttributedString {
        let line = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: editorial(step),
                .foregroundColor: DesignTokens.inkColor
            ]
        )
        let digitFont = digits(step)
        for number in numbers where number.isEmpty == false {
            var search = text.startIndex
            while let range = text.range(of: number, range: search..<text.endIndex) {
                line.addAttribute(.font, value: digitFont, range: NSRange(range, in: text))
                search = range.upperBound
            }
        }
        return line
    }

    private static func needsNewYork(_ category: UIContentSizeCategory) -> Bool {
        guard category != .unspecified else { return false }
        return category > .accessibilityMedium
    }

    static func numeral(_ text: String, step: Step) -> NSAttributedString {
        let font = copperplate(step)
        return NSAttributedString(
            string: text.uppercased(),
            attributes: [
                .font: font,
                .kern: 1.4,
                .foregroundColor: DesignTokens.inkColor
            ]
        )
    }
}

/// Card radius 14, chip radius 6, one soft shadow, filled capsules.
enum Chrome {
    static let cardRadius: CGFloat = 14
    static let chipRadius: CGFloat = 6
    static let unit: CGFloat = 8
    static let hit: CGFloat = 44

    static func applyShadow(to layer: CALayer) {
        layer.shadowColor = DesignTokens.inkColor.cgColor
        layer.shadowOpacity = 0.16
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
    }

    static func card(_ view: UIView) {
        view.backgroundColor = DesignTokens.surfaceColor
        view.layer.cornerRadius = cardRadius
        view.layer.cornerCurve = .continuous
        applyShadow(to: view.layer)
    }

    static func filledCapsule(_ button: UIButton, title: String) {
        verb(button, title: title, primary: true, enabled: true, capsule: true)
    }

    static func chip(_ button: UIButton, title: String, symbol: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.image = UIImage(systemName: symbol)
        config.imagePlacement = .leading
        config.imagePadding = unit
        config.baseBackgroundColor = DesignTokens.surfaceColor
        config.baseForegroundColor = DesignTokens.inkColor
        config.cornerStyle = .fixed
        config.background.cornerRadius = chipRadius
        config.contentInsets = NSDirectionalEdgeInsets(top: unit, leading: unit * 2, bottom: unit, trailing: unit * 2)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = TypeScale.copperplate(.micro)
            return outgoing
        }
        button.configuration = config
        button.accessibilityLabel = title
        pinHit(button)
        bindPress(button, primary: false, capsule: false)
    }

    /// Accent capsule for the live verb. Aim, Seal, and Post stay capsules when they wait.
    static func verb(_ button: UIButton, title: String, primary: Bool, enabled: Bool, capsule: Bool = false) {
        var config = button.configuration ?? UIButton.Configuration.filled()
        config.title = title
        config.image = nil
        config.baseForegroundColor = DesignTokens.bgColor
        if primary || capsule {
            config.cornerStyle = .capsule
        } else {
            config.cornerStyle = .fixed
            config.background.cornerRadius = chipRadius
        }
        config.contentInsets = NSDirectionalEdgeInsets(top: unit, leading: unit * 2, bottom: unit, trailing: unit * 2)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = TypeScale.copperplate(.caption)
            return outgoing
        }
        button.configuration = config
        button.accessibilityLabel = title
        button.isEnabled = enabled
        pinHit(button)
        bindPress(button, primary: primary, capsule: capsule)
        button.setNeedsUpdateConfiguration()
    }

    static func setEnabled(_ button: UIButton, enabled: Bool) {
        button.isEnabled = enabled
        button.setNeedsUpdateConfiguration()
    }

    static func numberPad(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.borderStyle = .none
        field.backgroundColor = DesignTokens.bgColor
        field.layer.cornerRadius = chipRadius
        field.font = TypeScale.digits(.body)
        field.textColor = DesignTokens.inkColor
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.accessibilityLabel = placeholder
        field.heightAnchor.constraint(greaterThanOrEqualToConstant: hit).isActive = true
        let bar = UIToolbar()
        bar.sizeToFit()
        let done = UIBarButtonItem(title: "Done", style: .done, target: field, action: #selector(UIResponder.resignFirstResponder))
        bar.items = [UIBarButtonItem(systemItem: .flexibleSpace), done]
        field.inputAccessoryView = bar
    }

    private static func pinHit(_ button: UIButton) {
        let existing = button.constraints.contains { $0.firstAttribute == .height && $0.relation == .greaterThanOrEqual }
        if existing == false {
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: hit).isActive = true
        }
    }

    static func dressTable(_ table: UITableView) {
        table.backgroundColor = DesignTokens.bgColor
        table.separatorStyle = .none
        table.sectionHeaderTopPadding = unit * 2
    }

    private static func bindPress(_ button: UIButton, primary: Bool, capsule: Bool) {
        button.configurationUpdateHandler = { button in
            guard var config = button.configuration else { return }
            let enabled = button.isEnabled
            let pressed = button.isHighlighted && enabled
            if primary {
                config.baseBackgroundColor = enabled ? DesignTokens.accentColor : DesignTokens.mutedColor
                config.baseForegroundColor = DesignTokens.bgColor
                config.cornerStyle = .capsule
            } else if capsule {
                config.baseBackgroundColor = DesignTokens.bgColor
                config.baseForegroundColor = enabled ? DesignTokens.inkColor : DesignTokens.mutedColor
                config.cornerStyle = .capsule
            } else {
                config.baseBackgroundColor = DesignTokens.surfaceColor
                config.baseForegroundColor = enabled ? DesignTokens.inkColor : DesignTokens.mutedColor
                config.cornerStyle = .fixed
                config.background.cornerRadius = chipRadius
            }
            button.configuration = config
            if UIAccessibility.isReduceMotionEnabled {
                button.transform = .identity
                button.alpha = pressed ? 0.72 : 1
            } else {
                button.alpha = 1
                let scale: CGFloat = pressed ? 0.97 : 1
                button.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
    }
}

/// Card rows. Plain tables keep the 14pt radius and the shared shadow.
final class PlatedCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Chrome.unit * 2,
            leading: Chrome.unit * 4,
            bottom: Chrome.unit * 2,
            trailing: Chrome.unit * 4
        )
        var background = UIBackgroundConfiguration.listPlainCell()
        background.backgroundColor = DesignTokens.surfaceColor
        background.cornerRadius = Chrome.cardRadius
        background.backgroundInsets = NSDirectionalEdgeInsets(
            top: Chrome.unit,
            leading: Chrome.unit * 2,
            bottom: Chrome.unit,
            trailing: Chrome.unit * 2
        )
        backgroundConfiguration = background
        Chrome.applyShadow(to: layer)
        layer.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = bounds.insetBy(dx: Chrome.unit * 2, dy: Chrome.unit)
        guard inset.width > 0, inset.height > 0 else { return }
        layer.shadowPath = UIBezierPath(roundedRect: inset, cornerRadius: Chrome.cardRadius).cgPath
    }
}

/// Goal counts, points, and day keys share one number formatter.
enum CountText {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = false
        return formatter
    }()

    static func string(_ value: Int) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
