import Foundation

/// Reads ReviewLaunch once after onboarding and maps keys to storyboard segues.
enum ReviewHook {
    static let fixtures = "showFixtures"
    static let standings = "showStandings"
    static let settings = "showSettings"
    static let onboarding = "showOnboarding"

    /// today leaves the board. log, goals, and settings open three other scenes.
    static func segue(for screen: String?) -> String? {
        switch screen {
        case "log":
            return fixtures
        case "goals":
            return standings
        case "settings":
            return settings
        default:
            return nil
        }
    }
}
