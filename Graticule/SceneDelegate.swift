import UIKit

/// Loads Board.storyboard and flushes the chart when the scene leaves the active state.
@MainActor
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var chartFlush: Task<Void, Never>?
    private var chartFlushToken: UIBackgroundTaskIdentifier = .invalid

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = BoardWindow.install(on: windowScene)
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        Task { @MainActor in
            BoardSession.shared.store.foldToday(DayKey.today())
            (window?.rootViewController as? BoardViewController)?.refreshForDay()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        persistChartBeforeSuspension()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        persistChartBeforeSuspension()
    }

    /// Begins a background task, then flushes. A force-quit after inactive still keeps the last mark.
    private func persistChartBeforeSuspension() {
        let application = UIApplication.shared
        if chartFlushToken == .invalid {
            chartFlushToken = application.beginBackgroundTask(withName: "grc.chart.flush") { [weak self] in
                Task { @MainActor in
                    self?.endChartFlushTask()
                }
            }
        }
        guard chartFlush == nil else { return }
        chartFlush = Task { @MainActor in
            await BoardSession.shared.store.sceneLeftActive()
            self.chartFlush = nil
            self.endChartFlushTask()
        }
    }

    private func endChartFlushTask() {
        let token = chartFlushToken
        guard token != .invalid else { return }
        chartFlushToken = .invalid
        UIApplication.shared.endBackgroundTask(token)
    }
}

/// Board.storyboard is the window's root. Scene connection and a late launch share this.
enum BoardWindow {
    @MainActor
    static func install(on scene: UIWindowScene) -> UIWindow {
        let storyboard = UIStoryboard(name: "Board", bundle: nil)
        let window = scene.windows.first ?? UIWindow(windowScene: scene)
        if window.rootViewController == nil {
            window.rootViewController = storyboard.instantiateInitialViewController()
        }
        window.tintColor = DesignTokens.accentColor
        window.backgroundColor = DesignTokens.bgColor
        window.makeKeyAndVisible()
        return window
    }
}

/// One chart for every scene. Screens talk only to the store.
@MainActor
final class BoardSession {
    static let shared = BoardSession()
    let store = BoardStore.live()
}
