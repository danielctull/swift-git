
import Foundation
import XCTest
import GitKit

final class BranchTests: XCTestCase {

    func testThrowsUnbornBranchError() throws {
        try FileManager.default.withTemporaryDirectory { url in
            let repository = try Repository(url: url)
            XCTAssertThrowsError(try repository.head()) { error in
                XCTAssertEqual((error as? GitError)?.code, .unbornBranch)
            }
        }
    }
}
