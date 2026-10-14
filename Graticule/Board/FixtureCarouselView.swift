import UIKit

/// Controls fused on the active tile. Neighbors stay name, phase, and kickoff.
struct FixtureTileState {
    var cells: [UUID: Cell] = [:]
    var skewedIDs: Set<UUID> = []
    var showGoals = false
    var aimEnabled = false
    var sealEnabled = false
    var postEnabled = false
    var aimLive = false
    var sealLive = false
    var postLive = false
    var homeGoals = ""
    var awayGoals = ""
}

/// Horizontal fixture carousel. The active tile is larger. Neighbors clip inside their frames.
final class FixtureCarouselView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var onSelect: ((UUID) -> Void)?
    var onAim: (() -> Void)?
    var onSeal: (() -> Void)?
    var onPost: ((String, String) -> Void)?
    private var fixtures: [Fixture] = []
    private var phases: [UUID: BoardPhase] = [:]
    private var activeID: UUID?
    private var tileState = FixtureTileState()
    private let collection: UICollectionView

    override init(frame: CGRect) {
        let layout = HeroCarouselLayout()
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(frame: frame)
        collection.backgroundColor = .clear
        collection.clipsToBounds = true
        collection.delaysContentTouches = false
        collection.showsHorizontalScrollIndicator = false
        collection.dataSource = self
        collection.delegate = self
        collection.register(FixtureTileCell.self, forCellWithReuseIdentifier: FixtureTileCell.reuse)
        collection.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collection)
        NSLayoutConstraint.activate([
            collection.leadingAnchor.constraint(equalTo: leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: trailingAnchor),
            collection.topAnchor.constraint(equalTo: topAnchor),
            collection.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func reload(fixtures: [Fixture], phases: [UUID: BoardPhase], active: UUID?, tile: FixtureTileState) {
        self.fixtures = fixtures
        self.phases = phases
        self.activeID = active
        self.tileState = tile
        collection.reloadData()
        guard let active, let index = fixtures.firstIndex(where: { $0.id == active }) else { return }
        let path = IndexPath(item: index, section: 0)
        collection.layoutIfNeeded()
        collection.scrollToItem(at: path, at: .centeredHorizontally, animated: false)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fixtures.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FixtureTileCell.reuse, for: indexPath)
        guard let tile = cell as? FixtureTileCell else { return cell }
        let fixture = fixtures[indexPath.item]
        let active = fixture.id == activeID
        tile.fill(
            fixture: fixture,
            phase: phases[fixture.id] ?? .open,
            cell: tileState.cells[fixture.id],
            active: active,
            skewed: tileState.skewedIDs.contains(fixture.id),
            state: active ? tileState : nil,
            onAim: { [weak self] in self?.onAim?() },
            onSeal: { [weak self] in self?.onSeal?() },
            onPost: { [weak self] home, away in self?.onPost?(home, away) }
        )
        return tile
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(fixtures[indexPath.item].id)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        publishCenter()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate { publishCenter() }
    }

    private func publishCenter() {
        let center = CGPoint(x: collection.contentOffset.x + collection.bounds.width / 2, y: collection.bounds.midY)
        guard let index = collection.indexPathForItem(at: center)?.item ?? nearestIndex() else { return }
        guard fixtures.indices.contains(index) else { return }
        onSelect?(fixtures[index].id)
    }

    private func nearestIndex() -> Int? {
        let center = collection.contentOffset.x + collection.bounds.width / 2
        var best: (index: Int, distance: CGFloat)?
        for cell in collection.visibleCells {
            guard let index = collection.indexPath(for: cell)?.item else { continue }
            let distance = abs(cell.center.x - center)
            if let current = best {
                if distance < current.distance {
                    best = (index, distance)
                }
            } else {
                best = (index, distance)
            }
        }
        return best?.index
    }
}

/// Centers the active tile and keeps neighbors smaller and behind it.
final class HeroCarouselLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        scrollDirection = .horizontal
        minimumLineSpacing = Chrome.unit * 2
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func prepare() {
        super.prepare()
        guard let collectionView else { return }
        let width = min(240, collectionView.bounds.width * 0.72)
        itemSize = CGSize(width: width, height: max(88, collectionView.bounds.height - Chrome.unit))
        let inset = max(Chrome.unit * 2, (collectionView.bounds.width - width) / 2)
        sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool { true }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect), let collectionView else {
            return super.layoutAttributesForElements(in: rect)
        }
        let mid = collectionView.contentOffset.x + collectionView.bounds.width / 2
        return attributes.compactMap { item in
            guard let copy = item.copy() as? UICollectionViewLayoutAttributes else { return nil }
            let distance = abs(copy.center.x - mid)
            let scale = max(0.84, 1 - distance / 700)
            copy.transform = CGAffineTransform(scaleX: scale, y: scale)
            copy.zIndex = Int(scale * 100)
            return copy
        }
    }
}

final class FixtureTileCell: UICollectionViewCell, UITextFieldDelegate {
    static let reuse = "FixtureTileCell"
    private let title = UILabel()
    private let phase = UILabel()
    private let swatch = UIView()
    private let day = UILabel()
    private let scoreLine = UILabel()
    private let skew = UILabel()
    private let homeGoals = UITextField()
    private let awayGoals = UITextField()
    private let aimButton = UIButton(type: .system)
    private let sealButton = UIButton(type: .system)
    private let postButton = UIButton(type: .system)
    private let liveRow = UIStackView()
    private let restRow = UIStackView()
    private let scoreRow = UIStackView()
    private let verbBlock = UIStackView()
    private var aimHandler: (() -> Void)?
    private var sealHandler: (() -> Void)?
    private var postHandler: ((String, String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = Chrome.cardRadius
        contentView.backgroundColor = DesignTokens.surfaceColor
        layer.cornerRadius = Chrome.cardRadius
        Chrome.applyShadow(to: layer)
        clipsToBounds = false

        title.font = TypeScale.copperplate(.caption)
        title.textColor = DesignTokens.inkColor
        title.numberOfLines = 2
        title.lineBreakMode = .byTruncatingTail
        title.adjustsFontForContentSizeCategory = true
        title.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        phase.font = TypeScale.copperplate(.micro)
        phase.textColor = DesignTokens.inkColor
        phase.adjustsFontForContentSizeCategory = true

        day.font = TypeScale.digits(.micro)
        day.textColor = DesignTokens.mutedColor
        day.adjustsFontForContentSizeCategory = true

        scoreLine.adjustsFontForContentSizeCategory = true
        scoreLine.numberOfLines = 1

        skew.font = TypeScale.editorial(.micro)
        skew.textColor = DesignTokens.inkColor
        skew.numberOfLines = 2
        skew.adjustsFontForContentSizeCategory = true
        skew.text = "A skew was recorded."

        swatch.layer.cornerRadius = Chrome.chipRadius
        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.widthAnchor.constraint(equalToConstant: Chrome.unit * 2).isActive = true
        swatch.heightAnchor.constraint(equalToConstant: Chrome.unit * 2).isActive = true

        Chrome.numberPad(homeGoals, placeholder: "Home goals")
        Chrome.numberPad(awayGoals, placeholder: "Away goals")
        homeGoals.delegate = self
        awayGoals.delegate = self

        scoreRow.addArrangedSubview(homeGoals)
        scoreRow.addArrangedSubview(awayGoals)
        scoreRow.axis = .horizontal
        scoreRow.spacing = Chrome.unit
        scoreRow.distribution = .fillEqually

        liveRow.axis = .horizontal
        liveRow.distribution = .fill
        restRow.axis = .horizontal
        restRow.spacing = Chrome.unit
        restRow.distribution = .fillEqually
        verbBlock.axis = .vertical
        verbBlock.spacing = Chrome.unit
        verbBlock.addArrangedSubview(scoreRow)
        verbBlock.addArrangedSubview(liveRow)
        verbBlock.addArrangedSubview(restRow)
        verbBlock.setContentCompressionResistancePriority(.required, for: .vertical)

        aimButton.addAction(UIAction { [weak self] _ in self?.aimHandler?() }, for: .touchUpInside)
        sealButton.addAction(UIAction { [weak self] _ in self?.sealHandler?() }, for: .touchUpInside)
        postButton.addAction(UIAction { [weak self] _ in
            self?.postHandler?(self?.homeGoals.text ?? "", self?.awayGoals.text ?? "")
        }, for: .touchUpInside)

        let phaseRow = UIStackView(arrangedSubviews: [swatch, phase])
        phaseRow.axis = .horizontal
        phaseRow.spacing = Chrome.unit
        phaseRow.alignment = .center

        let header = UIStackView(arrangedSubviews: [title, phaseRow, scoreLine, day, skew])
        header.axis = .vertical
        header.spacing = Chrome.unit
        header.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let stack = UIStackView(arrangedSubviews: [header, verbBlock])
        stack.axis = .vertical
        stack.spacing = Chrome.unit
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Chrome.unit * 2),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Chrome.unit * 2),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Chrome.unit),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Chrome.unit)
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let rect = contentView.frame
        guard rect.width > 0, rect.height > 0 else { return }
        layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: Chrome.cardRadius).cgPath
    }

    func fill(
        fixture: Fixture,
        phase phaseValue: BoardPhase,
        cell: Cell?,
        active: Bool,
        skewed: Bool,
        state: FixtureTileState?,
        onAim: @escaping () -> Void,
        onSeal: @escaping () -> Void,
        onPost: @escaping (String, String) -> Void
    ) {
        title.text = fixture.title.uppercased()
        phase.text = phaseValue.rawValue.uppercased()
        let dayKey = CountText.string(fixture.kickoffDayKey)
        day.attributedText = TypeScale.digitLine("Kickoff \(dayKey)", step: .micro, color: DesignTokens.mutedColor)
        swatch.backgroundColor = phaseValue == .open ? DesignTokens.mutedColor : DesignTokens.accentColor
        if let cell {
            let home = CountText.string(cell.home)
            let away = CountText.string(cell.away)
            scoreLine.isHidden = false
            scoreLine.attributedText = TypeScale.digitLine("\(home) to \(away)", step: .caption)
        } else {
            scoreLine.isHidden = true
            scoreLine.attributedText = nil
        }
        skew.isHidden = skewed == false
        verbBlock.isHidden = active == false
        verbBlock.isUserInteractionEnabled = active
        if active, let state {
            scoreRow.isHidden = state.showGoals == false
            if homeGoals.isFirstResponder == false {
                homeGoals.text = state.homeGoals
            }
            if awayGoals.isFirstResponder == false {
                awayGoals.text = state.awayGoals
            }
            Chrome.verb(aimButton, title: "Aim", primary: state.aimLive, enabled: state.aimEnabled, capsule: true)
            Chrome.verb(sealButton, title: "Seal", primary: state.sealLive, enabled: state.sealEnabled, capsule: true)
            Chrome.verb(postButton, title: "Post", primary: state.postLive, enabled: state.postEnabled, capsule: true)
            let ordered = [(aimButton, state.aimLive), (sealButton, state.sealLive), (postButton, state.postLive)]
            let live = ordered.first(where: { $0.1 })?.0
            let rest = ordered.compactMap { pair -> UIButton? in
                pair.0 === live ? nil : pair.0
            }
            place(live: live, rest: rest)
            aimHandler = onAim
            sealHandler = onSeal
            postHandler = onPost
        }
        isAccessibilityElement = active == false
        accessibilityLabel = "\(fixture.title), \(phaseValue.rawValue)"
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        return string.allSatisfy(\.isNumber)
    }

    private func place(live: UIButton?, rest: [UIButton]) {
        [aimButton, sealButton, postButton].forEach { $0.removeFromSuperview() }
        if let live {
            liveRow.addArrangedSubview(live)
            liveRow.isHidden = false
        } else {
            liveRow.isHidden = true
        }
        rest.forEach { restRow.addArrangedSubview($0) }
        restRow.isHidden = rest.isEmpty
    }
}
