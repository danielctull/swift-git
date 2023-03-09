
import Foundation
import Git
import XCTest

final class RemoteBranchTests: XCTestCase {

    func testRepositoryRemoteBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranches = try repo.remoteBranches
            XCTAssertEqual(remoteBranches.count, 2)
            XCTAssertEqual(try remoteBranches.value(at: 0).id, "refs/remotes/origin/HEAD")
            XCTAssertEqual(try remoteBranches.value(at: 0).name, "origin/HEAD")
            XCTAssertEqual(try remoteBranches.value(at: 0).remote, "origin")
            XCTAssertEqual(try remoteBranches.value(at: 0).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try remoteBranches.value(at: 1).id, "refs/remotes/origin/main")
            XCTAssertEqual(try remoteBranches.value(at: 1).name, "origin/main")
            XCTAssertEqual(try remoteBranches.value(at: 1).remote, "origin")
            XCTAssertEqual(try remoteBranches.value(at: 1).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }

    func testRepositoryRemoteBranchNamed() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranch = try repo.remoteBranch(on: "origin", named: "main")
            XCTAssertEqual(remoteBranch.name, "origin/main")
            XCTAssertEqual(remoteBranch.id, "refs/remotes/origin/main")
            XCTAssertEqual(remoteBranch.remote, "origin")
            XCTAssertEqual(remoteBranch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }
}
