import UIKit
import SpriteKit

/// Home. The fixture carousel and the 4×4 lattice stay on this screen.
/// Aim, Seal, and Post fuse on the active tile.
final class BoardViewController: UIViewController {
    private let store = BoardSession.shared.store
    private let carousel = FixtureCarouselView()
    private let lattice = LatticeView()
    private let titleLabel = UILabel()
    private let caption = UILabel()
    private let pointsCard = UIView()
    private let pointsStack = UIStackView()
    private let peelButton = UIButton(type: .system)
    private let tipsterRow = UIStackView()
    private let emptyState = UIView()
    private let readFailure = UILabel()
    private let burstView = SKView()
    private let burstScene = BullseyeBurstScene(size: CGSize(width: 180, height: 180))
    private var pendingCell: Cell?
    private var didReadReview = false
    private var burstToken = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.bgColor
        build()
        lattice.onSelect = { [weak self] cell in
            self?.pendingCell = cell
            self?.render()
        }
        carousel.onSelect = { [weak self] id in
            self?.pendingCell = nil
            self?.store.selectFixture(id)
            self?.render()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        store.foldToday(DayKey.today())
        render()
        guard store.chart.onboardingComplete else {
            if presentedViewController == nil {
                performSegue(withIdentifier: ReviewHook.onboarding, sender: self)
            }
            return
        }
        guard didReadReview == false else { return }
        didReadReview = true
        if let segue = ReviewHook.segue(for: ReviewLaunch.screen) {
            performSegue(withIdentifier: segue, sender: self)
        }
    }

    private func build() {
        let wordmark = UILabel()
        wordmark.attributedText = TypeScale.numeral("Tigroeb", step: .title)
        wordmark.adjustsFontForContentSizeCategory = true
        wordmark.numberOfLines = 1
        wordmark.accessibilityTraits = .header

        titleLabel.font = TypeScale.copperplate(.title)
        titleLabel.textColor = DesignTokens.inkColor
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.attributedText = TypeScale.numeral("Week board", step: .title)

        caption.font = TypeScale.editorial(.body)
        caption.textColor = DesignTokens.inkColor
        caption.numberOfLines = 0
        caption.adjustsFontForContentSizeCategory = true

        pointsStack.axis = .vertical
        pointsStack.spacing = Chrome.unit
        Chrome.card(pointsCard)
        let pointsTitle = UILabel()
        pointsTitle.attributedText = TypeScale.numeral("Posted points", step: .caption)
        pointsTitle.adjustsFontForContentSizeCategory = true
        pointsTitle.numberOfLines = 1
        let pointsInner = UIStackView(arrangedSubviews: [pointsTitle, pointsStack])
        pointsInner.axis = .vertical
        pointsInner.spacing = Chrome.unit
        pointsInner.translatesAutoresizingMaskIntoConstraints = false
        pointsCard.addSubview(pointsInner)
        NSLayoutConstraint.activate([
            pointsInner.leadingAnchor.constraint(equalTo: pointsCard.leadingAnchor, constant: Chrome.unit * 2),
            pointsInner.trailingAnchor.constraint(equalTo: pointsCard.trailingAnchor, constant: -Chrome.unit * 2),
            pointsInner.topAnchor.constraint(equalTo: pointsCard.topAnchor, constant: Chrome.unit * 2),
            pointsInner.bottomAnchor.constraint(equalTo: pointsCard.bottomAnchor, constant: -Chrome.unit * 2)
        ])

        tipsterRow.axis = .horizontal
        tipsterRow.spacing = Chrome.unit
        tipsterRow.alignment = .fill

        let tipsterScroll = UIScrollView()
        tipsterScroll.showsHorizontalScrollIndicator = false
        tipsterScroll.translatesAutoresizingMaskIntoConstraints = false
        tipsterRow.translatesAutoresizingMaskIntoConstraints = false
        tipsterScroll.addSubview(tipsterRow)
        NSLayoutConstraint.activate([
            tipsterRow.leadingAnchor.constraint(equalTo: tipsterScroll.contentLayoutGuide.leadingAnchor),
            tipsterRow.trailingAnchor.constraint(equalTo: tipsterScroll.contentLayoutGuide.trailingAnchor),
            tipsterRow.topAnchor.constraint(equalTo: tipsterScroll.contentLayoutGuide.topAnchor),
            tipsterRow.bottomAnchor.constraint(equalTo: tipsterScroll.contentLayoutGuide.bottomAnchor),
            tipsterRow.heightAnchor.constraint(equalTo: tipsterScroll.frameLayoutGuide.heightAnchor)
        ])
        tipsterScroll.heightAnchor.constraint(equalToConstant: Chrome.hit).isActive = true

        Chrome.verb(peelButton, title: "Peel", primary: false, enabled: true)
        peelButton.addAction(UIAction { [weak self] _ in self?.peel() }, for: .touchUpInside)
        carousel.onAim = { [weak self] in self?.aim() }
        carousel.onSeal = { [weak self] in self?.seal() }
        carousel.onPost = { [weak self] home, away in self?.post(homeText: home, awayText: away) }

        let plate = UIView()
        Chrome.card(plate)
        let plateStack = UIStackView(arrangedSubviews: [lattice, peelButton])
        plateStack.axis = .vertical
        plateStack.spacing = Chrome.unit
        plateStack.translatesAutoresizingMaskIntoConstraints = false
        plate.addSubview(plateStack)
        NSLayoutConstraint.activate([
            plateStack.leadingAnchor.constraint(equalTo: plate.leadingAnchor, constant: Chrome.unit * 2),
            plateStack.trailingAnchor.constraint(equalTo: plate.trailingAnchor, constant: -Chrome.unit * 2),
            plateStack.topAnchor.constraint(equalTo: plate.topAnchor, constant: Chrome.unit * 2),
            plateStack.bottomAnchor.constraint(equalTo: plate.bottomAnchor, constant: -Chrome.unit * 2),
            lattice.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])

        burstView.allowsTransparency = true
        burstView.backgroundColor = .clear
        burstScene.backgroundColor = .clear
        burstView.presentScene(burstScene)
        burstView.alpha = 0
        burstView.isUserInteractionEnabled = false
        burstView.translatesAutoresizingMaskIntoConstraints = false

        let fixtures = sheetButton("Fixtures", "calendar", ReviewHook.fixtures)
        let standings = sheetButton("Standings", "list.number", ReviewHook.standings)
        let settings = sheetButton("Settings", "gearshape", ReviewHook.settings)
        let sheets = UIStackView(arrangedSubviews: [fixtures, standings, settings])
        sheets.axis = .horizontal
        sheets.spacing = Chrome.unit
        sheets.distribution = .fillEqually

        carousel.translatesAutoresizingMaskIntoConstraints = false
        carousel.heightAnchor.constraint(equalToConstant: Chrome.unit * 42).isActive = true

        let column = UIStackView(arrangedSubviews: [wordmark, titleLabel, caption, tipsterScroll, carousel, plate, pointsCard, sheets])
        column.axis = .vertical
        column.spacing = Chrome.unit * 2
        column.translatesAutoresizingMaskIntoConstraints = false

        let scroll = UIScrollView()
        scroll.keyboardDismissMode = .interactive
        scroll.translatesAutoresizingMaskIntoConstraints = false
        let dismissKeys = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        dismissKeys.cancelsTouchesInView = false
        scroll.addGestureRecognizer(dismissKeys)
        scroll.addSubview(column)
        view.addSubview(scroll)
        view.addSubview(burstView)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.unit * 2),
            scroll.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.unit * 2),
            scroll.topAnchor.constraint(equalTo: safe.topAnchor, constant: Chrome.unit),
            scroll.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            column.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            column.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            column.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            column.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            column.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            burstView.centerXAnchor.constraint(equalTo: plate.centerXAnchor),
            burstView.centerYAnchor.constraint(equalTo: lattice.centerYAnchor),
            burstView.widthAnchor.constraint(equalToConstant: 180),
            burstView.heightAnchor.constraint(equalToConstant: 180)
        ])
        buildEmpty()
    }

    private func buildEmpty() {
        emptyState.backgroundColor = DesignTokens.bgColor
        emptyState.translatesAutoresizingMaskIntoConstraints = false
        let art = UIImageView(image: UIImage(named: "grc_EmptyHome"))
        art.contentMode = .scaleAspectFit
        art.heightAnchor.constraint(equalToConstant: 180).isActive = true
        let headline = UILabel()
        headline.font = TypeScale.copperplate(.title)
        headline.textColor = DesignTokens.inkColor
        headline.numberOfLines = 0
        headline.text = "The board has no fixtures yet."
        readFailure.font = TypeScale.editorial(.body)
        readFailure.textColor = DesignTokens.inkColor
        readFailure.numberOfLines = 0
        readFailure.isHidden = true
        let line = UILabel()
        line.font = TypeScale.editorial(.body)
        line.textColor = DesignTokens.mutedColor
        line.numberOfLines = 0
        line.text = "Add a match, aim a score, and seal it before kickoff."
        let button = UIButton(type: .system)
        Chrome.filledCapsule(button, title: "Add a fixture")
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.performSegue(withIdentifier: ReviewHook.fixtures, sender: self)
        }, for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [art, headline, readFailure, line, UIView(), button])
        stack.axis = .vertical
        stack.spacing = Chrome.unit * 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        emptyState.addSubview(stack)
        view.addSubview(emptyState)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            emptyState.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyState.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyState.topAnchor.constraint(equalTo: view.topAnchor),
            emptyState.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.unit * 2),
            stack.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.unit * 2),
            stack.topAnchor.constraint(equalTo: safe.topAnchor, constant: Chrome.unit * 3),
            stack.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Chrome.unit * 2)
        ])
    }

    func refreshForDay() {
        store.foldToday(DayKey.today())
        render()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func sheetButton(_ title: String, _ symbol: String, _ identifier: String) -> UIButton {
        let button = UIButton(type: .system)
        Chrome.chip(button, title: title, symbol: symbol)
        button.addAction(UIAction { [weak self] _ in
            self?.performSegue(withIdentifier: identifier, sender: self)
        }, for: .touchUpInside)
        return button
    }

    private func render() {
        let chart = store.chart
        emptyState.isHidden = chart.fixtures.isEmpty == false
        let tipster = chart.activeTipsterID.flatMap { chart.tipster($0) } ?? chart.tipsters.first
        let fixture = chart.activeFixtureID.flatMap { chart.fixture($0) } ?? chart.fixtures.first
        var phases: [UUID: BoardPhase] = [:]
        var cells: [UUID: Cell] = [:]
        if let tipster {
            for line in tipster.lines {
                phases[line.fixtureID] = line.phase
                if let cell = line.cell {
                    cells[line.fixtureID] = cell
                }
            }
        }
        let line = fixture.flatMap { fixture in tipster?.line(for: fixture.id) }
        let phase = line?.phase ?? .open
        let today = DayKey.today()
        let beforeKickoff = fixture.map { today < $0.kickoffDayKey } ?? false
        let aimEnabled = phase == .open || phase == .aimed
        let sealEnabled = phase == .aimed && beforeKickoff
        let postEnabled = phase == .sealed && beforeKickoff == false && fixture?.hasFinalScore == false
        carousel.reload(
            fixtures: chart.fixtures,
            phases: phases,
            active: fixture?.id,
            tile: FixtureTileState(
                cells: cells,
                skewedIDs: Set(tipster?.skewMarks.map(\.fixtureID) ?? []),
                showGoals: phase == .posted || postEnabled,
                aimEnabled: aimEnabled,
                sealEnabled: sealEnabled,
                postEnabled: postEnabled,
                aimLive: phase == .open && aimEnabled,
                sealLive: sealEnabled,
                postLive: postEnabled,
                homeGoals: fixture?.finalHome.map(CountText.string) ?? "",
                awayGoals: fixture?.finalAway.map(CountText.string) ?? ""
            )
        )
        rebuildTipsters(active: tipster?.id)

        lattice.show(aimed: line?.cell, pending: pendingCell)
        rebuildPoints()
        readFailure.text = store.loadNotice
        readFailure.isHidden = store.loadNotice == nil

        let aimed = line?.cell
        let skewed = fixture.map { id in tipster?.skewMarks.contains { $0.fixtureID == id.id } ?? false } ?? false
        if let fixture, let aimed, phase == .aimed, beforeKickoff {
            let home = CountText.string(aimed.home)
            let away = CountText.string(aimed.away)
            titleLabel.attributedText = TypeScale.numeral("Seal this score", step: .title)
            if skewed {
                caption.attributedText = TypeScale.editorialLine(
                    "A skew was recorded. Seal \(fixture.homeSide) \(home) to \(away) before kickoff.",
                    numbers: [home, away]
                )
            } else {
                caption.attributedText = TypeScale.editorialLine(
                    "Seal \(fixture.homeSide) \(home) to \(away) before kickoff.",
                    numbers: [home, away]
                )
            }
        } else if phase == .sealed, beforeKickoff == false, fixture?.hasFinalScore == false {
            titleLabel.attributedText = TypeScale.numeral("Post the goals", step: .title)
            caption.text = "This cell is sealed. Enter the final goals, then post."
        } else if phase == .posted, let fixture, let home = fixture.finalHome, let away = fixture.finalAway {
            let homeText = CountText.string(home)
            let awayText = CountText.string(away)
            titleLabel.attributedText = TypeScale.numeral("Score posted", step: .title)
            caption.attributedText = TypeScale.editorialLine(
                "Posted \(homeText) to \(awayText).",
                numbers: [homeText, awayText]
            )
        } else if phase == .void {
            titleLabel.attributedText = TypeScale.numeral("Kickoff void", step: .title)
            caption.text = "Kickoff passed before a seal, so this fixture is void."
        } else if phase == .sealed {
            titleLabel.attributedText = TypeScale.numeral("Cell sealed", step: .title)
            caption.text = "This cell is sealed. Post waits until the kickoff day."
        } else if let notice = store.loadNotice {
            titleLabel.attributedText = TypeScale.numeral("Week board", step: .title)
            caption.text = notice
        } else {
            titleLabel.attributedText = TypeScale.numeral("Aim a score", step: .title)
            caption.text = "Choose a square, then aim that exact score."
        }

        let peelEnabled = (phase == .aimed || phase == .sealed) && beforeKickoff
        Chrome.verb(peelButton, title: "Peel", primary: false, enabled: peelEnabled)
    }

    private func rebuildPoints() {
        pointsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let rows = store.standings().sorted { lhs, rhs in
            if lhs.points != rhs.points { return lhs.points > rhs.points }
            return lhs.name < rhs.name
        }
        if rows.isEmpty {
            let empty = UILabel()
            empty.font = TypeScale.editorial(.body)
            empty.textColor = DesignTokens.inkColor
            empty.numberOfLines = 0
            empty.text = "No scores are posted yet."
            pointsStack.addArrangedSubview(empty)
            return
        }
        for (index, standing) in rows.enumerated() {
            let name = UILabel()
            name.font = TypeScale.editorial(index == 0 ? .headline : .body)
            name.textColor = DesignTokens.inkColor
            name.text = standing.name
            name.numberOfLines = 1
            name.lineBreakMode = .byTruncatingTail
            name.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            let points = UILabel()
            let ink: UIColor = index == 0 ? DesignTokens.accentColor : DesignTokens.inkColor
            points.attributedText = TypeScale.digitLine(
                CountText.string(standing.points),
                step: index == 0 ? .display : .headline,
                color: ink
            )
            points.setContentCompressionResistancePriority(.required, for: .horizontal)
            points.setContentHuggingPriority(.required, for: .horizontal)
            let row = UIStackView(arrangedSubviews: [name, points])
            row.axis = .horizontal
            row.spacing = Chrome.unit * 2
            row.alignment = .firstBaseline
            pointsStack.addArrangedSubview(row)
        }
    }

    private func rebuildTipsters(active: UUID?) {
        tipsterRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tipster in store.chart.tipsters {
            let button = UIButton(type: .system)
            let selected = tipster.id == active
            Chrome.verb(button, title: tipster.name, primary: selected, enabled: true)
            button.addAction(UIAction { [weak self] _ in
                self?.store.selectTipster(tipster.id)
                self?.pendingCell = nil
                self?.render()
            }, for: .touchUpInside)
            tipsterRow.addArrangedSubview(button)
        }
    }

    private func aim() {
        guard let tipster = activeTipster(), let fixture = activeFixture() else { return }
        let line = tipster.line(for: fixture.id)
        let cell = pendingCell ?? line?.cell
        guard let cell else {
            caption.text = "Choose a square on the lattice, then aim."
            return
        }
        let outcome = store.aim(tipsterID: tipster.id, fixtureID: fixture.id, cell: cell, today: DayKey.today())
        finish(outcome, success: "Aimed \(CountText.string(cell.home)) to \(CountText.string(cell.away)).")
    }

    private func seal() {
        guard let tipster = activeTipster(), let fixture = activeFixture() else { return }
        let outcome = store.seal(tipsterID: tipster.id, fixtureID: fixture.id, today: DayKey.today())
        finish(outcome, success: "Sealed before kickoff.")
    }

    private func peel() {
        guard let tipster = activeTipster(), let fixture = activeFixture() else { return }
        let outcome = store.peel(tipsterID: tipster.id, fixtureID: fixture.id, today: DayKey.today())
        finish(outcome, success: "Peeled the last mark.")
    }

    private func post(homeText: String, awayText: String) {
        guard let fixture = activeFixture() else { return }
        guard let home = Int(homeText), let away = Int(awayText), home >= 0, away >= 0 else {
            caption.text = "Enter each side as a whole number from zero up."
            return
        }
        let outcome = store.post(fixtureID: fixture.id, finalHome: home, finalAway: away, today: DayKey.today())
        if outcome.bullseyeLanded {
            playBurst()
        }
        finish(outcome, success: "Posted \(CountText.string(home)) to \(CountText.string(away)).")
    }

    private func finish(_ outcome: BoardFold.Outcome, success: String) {
        if let refusal = outcome.refusal {
            render()
            if activePhase() != .void {
                caption.text = refusal.sentence
            }
            return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        pendingCell = nil
        caption.text = success
        render()
    }

    private func playBurst() {
        burstToken += 1
        let token = burstToken
        burstScene.size = burstView.bounds.size == .zero ? CGSize(width: 180, height: 180) : burstView.bounds.size
        if UIAccessibility.isReduceMotionEnabled {
            pointsCard.alpha = 0
            UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
                self.pointsCard.alpha = 1
            }
            return
        }
        burstScene.play()
        burstView.alpha = 0
        UIView.animate(withDuration: 0.18, delay: 0, options: .curveEaseOut) {
            self.burstView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.18, delay: 0.05, options: .curveEaseOut) {
                if token == self.burstToken {
                    self.burstView.alpha = 0
                }
            }
        }
    }

    private func activePhase() -> BoardPhase {
        guard let tipster = activeTipster(), let fixture = activeFixture() else { return .open }
        return tipster.line(for: fixture.id)?.phase ?? .open
    }

    private func activeTipster() -> Tipster? {
        let chart = store.chart
        return chart.activeTipsterID.flatMap { chart.tipster($0) } ?? chart.tipsters.first
    }

    private func activeFixture() -> Fixture? {
        let chart = store.chart
        return chart.activeFixtureID.flatMap { chart.fixture($0) } ?? chart.fixtures.first
    }
}

extension BoardFold.Refusal {
    var sentence: String {
        switch self {
        case .aimRefused:
            return "This fixture is sealed, so the cell stays."
        case .sealAfterKickoff:
            return "Kickoff has arrived, so this cell cannot be sealed."
        case .negativeScore:
            return "Enter each side as a whole number from zero up."
        case .postBeforeKickoff:
            return "Post waits until the kickoff day."
        case .notAimed:
            return "Aim a cell before you seal it."
        case .peelRefused:
            return "Peel is only available before kickoff."
        case .invalidCell:
            return "Choose a square from zero to three on each side."
        case .emptyName:
            return "Enter a name for this tipster."
        case .invalidDayKey:
            return "Enter the kickoff as a daykey, such as a year month and day."
        case .unknownFixture, .unknownTipster:
            return "That fixture is no longer on the board."
        }
    }
}
