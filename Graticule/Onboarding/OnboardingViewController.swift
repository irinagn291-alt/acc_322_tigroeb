import UIKit

/// Three pages. Continue sits full width at the bottom. Skip writes one tipster and an empty board.
final class OnboardingViewController: UIViewController, UICollectionViewDataSource {
    private let store = BoardSession.shared.store
    private let pages: [(image: String, headline: String, line: String)] = [
        (
            "grc_Onboarding1",
            "Aim an exact score.",
            "Friends on this phone share one lattice. Points stay on the standings."
        ),
        (
            "grc_Onboarding2",
            "Seal the cell before kickoff.",
            "A second aim without peel records a skew and keeps the cell."
        ),
        (
            "grc_Onboarding3",
            "Post the final goals.",
            "An exact cell is a bullseye at 9. The right winner on another cell is near at 3. A wrong winner is flat at 0."
        )
    ]
    private var collection: UICollectionView!
    private let pageControl = UIPageControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignTokens.bgColor
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.isPagingEnabled = true
        collection.dataSource = self
        collection.delegate = self
        collection.showsHorizontalScrollIndicator = false
        collection.register(OnboardingPageCell.self, forCellWithReuseIdentifier: OnboardingPageCell.reuse)
        pageControl.numberOfPages = pages.count
        pageControl.currentPageIndicatorTintColor = DesignTokens.accentColor
        pageControl.pageIndicatorTintColor = DesignTokens.mutedColor
        let continueButton = UIButton(type: .system)
        Chrome.filledCapsule(continueButton, title: "Continue")
        continueButton.addAction(UIAction { [weak self] _ in self?.advance() }, for: .touchUpInside)
        let skip = UIButton(type: .system)
        Chrome.verb(skip, title: "Skip", primary: false, enabled: true)
        skip.addAction(UIAction { [weak self] _ in self?.finish(skip: true) }, for: .touchUpInside)
        let column = UIStackView(arrangedSubviews: [collection, pageControl, skip, continueButton])
        column.axis = .vertical
        column.spacing = Chrome.unit * 2
        column.translatesAutoresizingMaskIntoConstraints = false
        collection.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(column)
        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            column.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: Chrome.unit * 2),
            column.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -Chrome.unit * 2),
            column.topAnchor.constraint(equalTo: safe.topAnchor, constant: Chrome.unit * 2),
            column.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -Chrome.unit * 2),
            pageControl.heightAnchor.constraint(equalToConstant: Chrome.hit)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let layout = collection.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize = collection.bounds.size
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingPageCell.reuse, for: indexPath)
        guard let page = cell as? OnboardingPageCell else { return cell }
        let item = pages[indexPath.item]
        page.fill(image: item.image, headline: item.headline, line: item.line)
        return page
    }

    private func advance() {
        let page = pageControl.currentPage
        if page + 1 < pages.count {
            let next = IndexPath(item: page + 1, section: 0)
            collection.scrollToItem(at: next, at: .centeredHorizontally, animated: true)
            pageControl.currentPage = page + 1
            return
        }
        finish(skip: false)
    }

    private func finish(skip: Bool) {
        if skip, store.chart.tipsters.isEmpty, store.chart.fixtures.isEmpty {
            _ = store.addTipster(name: "You")
        } else if store.chart.tipsters.isEmpty {
            _ = store.addTipster(name: "You")
        }
        store.markOnboardingComplete()
        dismiss(animated: true)
    }
}

extension OnboardingViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = max(scrollView.bounds.width, 1)
        pageControl.currentPage = Int(scrollView.contentOffset.x / width)
    }
}

final class OnboardingPageCell: UICollectionViewCell {
    static let reuse = "OnboardingPageCell"
    private let art = UIImageView()
    private let headline = UILabel()
    private let line = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        art.contentMode = .scaleAspectFit
        art.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        art.setContentHuggingPriority(.defaultLow, for: .vertical)
        headline.font = TypeScale.copperplate(.title)
        headline.textColor = DesignTokens.inkColor
        headline.numberOfLines = 0
        headline.adjustsFontForContentSizeCategory = true
        headline.setContentCompressionResistancePriority(.required, for: .vertical)
        line.font = TypeScale.editorial(.body)
        line.textColor = DesignTokens.mutedColor
        line.numberOfLines = 0
        line.adjustsFontForContentSizeCategory = true
        line.setContentCompressionResistancePriority(.required, for: .vertical)
        let stack = UIStackView(arrangedSubviews: [art, headline, line])
        stack.axis = .vertical
        stack.spacing = Chrome.unit * 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        contentView.addSubview(scroll)
        let artCap = art.heightAnchor.constraint(lessThanOrEqualToConstant: Chrome.unit * 28)
        artCap.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scroll.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scroll.topAnchor.constraint(equalTo: contentView.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor),
            artCap
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    func fill(image: String, headline: String, line: String) {
        art.image = UIImage(named: image)
        self.headline.text = headline
        self.line.text = line
    }
}
