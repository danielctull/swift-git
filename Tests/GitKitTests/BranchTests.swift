
import Foundation
import GitKit
import XCTest

final class BranchTests: XCTestCase {

    func testRepositoryBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branches = try repo.branches()
            XCTAssertEqual(branches.count, 1)
            let branch = try XCTUnwrap(branches.first)
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.id, "refs/heads/main")
            XCTAssertEqual(branch.objectID.description, "17e26bc76cff375603e7173dac31e5183350e559")
        }
    }

    func testRepositoryBranchNamed() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branch = try repo.branch(named: "main")
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.id, "refs/heads/main")
            XCTAssertEqual(branch.objectID.description, "17e26bc76cff375603e7173dac31e5183350e559")
        }
    }
}
