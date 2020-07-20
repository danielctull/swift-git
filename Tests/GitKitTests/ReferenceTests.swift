
import Foundation
import XCTest
import GitKit

final class ReferenceTests: XCTestCase {

    func testThrowsUnbornBranchError() throws {
        try FileManager.default.withTemporaryDirectory { url in
            let repository = try Repository(url: url)
            XCTAssertThrowsError(try repository.head()) { error in
                XCTAssertEqual((error as? GitError)?.code, .unbornBranch)
            }
        }
    }

    func testHead() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repository = try Repository(local: local, remote: remote)
            let head = try repository.head()
            guard case let .branch(branch) = head else { XCTFail("Expected branch"); return }
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.id, Branch.ID(rawValue: "refs/heads/main"))
        }
    }
}
