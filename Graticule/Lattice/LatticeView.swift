import UIKit

/// Sixteen placed squares. An unchosen cell stays an empty square.
final class LatticeView: UIView {
    var onSelect: ((Cell) -> Void)?
    private var buttons: [UIButton] = []
    private let grid = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        grid.axis = .vertical
        grid.distribution = .fillEqually
        grid.spacing = Chrome.unit
        grid.translatesAutoresizingMaskIntoConstraints = false
        addSubview(grid)
        NSLayoutConstraint.activate([
            grid.leadingAnchor.constraint(equalTo: leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: trailingAnchor),
            grid.topAnchor.constraint(equalTo: topAnchor),
            grid.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        for home in 0..<Lattice.span {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = Chrome.unit
            for away in 0..<Lattice.span {
                let cell = Cell(home: home, away: away)
                let button = UIButton(type: .system)
                button.tag = home * Lattice.span + away
                button.layer.cornerRadius = Chrome.chipRadius
                button.layer.borderWidth = 1
                button.layer.borderColor = DesignTokens.mutedColor.cgColor
                button.accessibilityLabel = "Score \(CountText.string(home)) to \(CountText.string(away))"
                button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
                button.addAction(UIAction { [weak self] _ in
                    self?.onSelect?(cell)
                }, for: .touchUpInside)
                buttons.append(button)
                row.addArrangedSubview(button)
            }
            grid.addArrangedSubview(row)
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    func show(aimed: Cell?, pending: Cell?) {
        for button in buttons {
            let home = button.tag / Lattice.span
            let away = button.tag % Lattice.span
            let cell = Cell(home: home, away: away)
            let chosen = aimed == cell
            let waiting = pending == cell && aimed != cell
            button.backgroundColor = chosen ? DesignTokens.inkColor : DesignTokens.bgColor
            button.layer.borderColor = chosen
                ? DesignTokens.accentColor.cgColor
                : (waiting ? DesignTokens.inkColor.cgColor : DesignTokens.mutedColor.cgColor)
            button.layer.borderWidth = (chosen || waiting) ? 2 : 1
            let ink = chosen ? DesignTokens.surfaceColor : DesignTokens.inkColor
            let pair = "\(CountText.string(home)) \(CountText.string(away))"
            button.setAttributedTitle(TypeScale.digitLine(pair, step: .micro, color: ink), for: .normal)
            button.setTitleColor(ink, for: .normal)
            button.accessibilityValue = chosen ? "Aimed" : "Empty"
        }
    }
}
