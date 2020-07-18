
import Foundation
import XCTest
import GitKit

final class RepositoryTests: XCTestCase {

    func testCreate() throws {
        try FileManager.default.withTemporaryDirectory { url in
            XCTAssertNoThrow(try Repository(url: url))
        }
    }
}
