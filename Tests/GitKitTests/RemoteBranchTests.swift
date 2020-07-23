
import Foundation
import GitKit
import XCTest

final class RemoteBranchTests: XCTestCase {

    func testRepositoryRemoteBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranches = try repo.remoteBranches()
            XCTAssertEqual(remoteBranches.count, 1)
            let main = try XCTUnwrap(remoteBranches.first)
            XCTAssertEqual(main.name, "origin/main")
            XCTAssertEqual(main.id, "refs/remotes/origin/main")
        }
    }

    func testRepositoryRemoteBranchNamed() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranch = try repo.remoteBranch(named: "origin/main")
            XCTAssertEqual(remoteBranch.name, "origin/main")
            XCTAssertEqual(remoteBranch.id, "refs/remotes/origin/main")
        }
    }
}
