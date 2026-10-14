import XCTest
@testable import Graticule

final class ReviewLaunchTests: XCTestCase {
    func testParsesReviewScreenArgument() {
        XCTAssertEqual(
            ReviewLaunch.screen(from: ["Graticule", ReviewLaunch.argument, "today"]),
            "today"
        )
        XCTAssertEqual(
            ReviewLaunch.screen(from: ["Graticule", ReviewLaunch.argument, "log"]),
            "log"
        )
        XCTAssertEqual(
            ReviewLaunch.screen(from: ["Graticule", ReviewLaunch.argument, "goals"]),
            "goals"
        )
        XCTAssertNil(ReviewLaunch.screen(from: ["Graticule"]))
        XCTAssertNil(ReviewLaunch.screen(from: ["Graticule", ReviewLaunch.argument]))
    }
}
