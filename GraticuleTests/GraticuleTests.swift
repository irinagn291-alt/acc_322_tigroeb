import XCTest
@testable import Graticule

/// Placeholder. Replace with the cases required by SPEC.md section 17.
final class GraticuleTests: XCTestCase {
    func test_appModuleImports() {
        XCTAssertEqual(String(describing: GraticuleApp.self), "GraticuleApp")
    }
}
