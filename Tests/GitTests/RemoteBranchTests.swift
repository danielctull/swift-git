
import Foundation
import Git
import XCTest

@GitActor
final class RemoteBranchTests: XCTestCase {

    func testRepositoryRemoteBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranches = try Array(repo.remoteBranches)
            XCTAssertEqual(remoteBranches.count, 2)
            XCTAssertEqual(try remoteBranches.value(at: 0).id.description, "refs/remotes/origin/HEAD")
            XCTAssertEqual(try remoteBranches.value(at: 0).reference.description, "refs/remotes/origin/HEAD")
            XCTAssertEqual(try remoteBranches.value(at: 0).name.description, "origin/HEAD")
            XCTAssertEqual(try remoteBranches.value(at: 0).name.remote, "origin")
            XCTAssertEqual(try remoteBranches.value(at: 0).name.branch, "HEAD")
            XCTAssertEqual(try remoteBranches.value(at: 0).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(try remoteBranches.value(at: 1).id.description, "refs/remotes/origin/main")
            XCTAssertEqual(try remoteBranches.value(at: 1).reference.description, "refs/remotes/origin/main")
            XCTAssertEqual(try remoteBranches.value(at: 1).name.description, "origin/main")
            XCTAssertEqual(try remoteBranches.value(at: 1).name.remote, "origin")
            XCTAssertEqual(try remoteBranches.value(at: 1).name.branch, "main")
            XCTAssertEqual(try remoteBranches.value(at: 1).target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }

    func testRepositoryRemoteBranchNamed() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranch = try repo.branch(on: "origin", named: "main")
            XCTAssertEqual(remoteBranch.name.description, "origin/main")
            XCTAssertEqual(remoteBranch.id.description, "refs/remotes/origin/main")
            XCTAssertEqual(remoteBranch.reference.description, "refs/remotes/origin/main")
            XCTAssertEqual(remoteBranch.name.remote, "origin")
            XCTAssertEqual(remoteBranch.name.branch, "main")
            XCTAssertEqual(remoteBranch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }

    func testDelete() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranch = try repo.branch(on: "origin", named: "main")
            try repo.delete(.remoteBranch(remoteBranch))
            XCTAssertThrowsError(try repo.branch(on: "origin", named: "main"))

            // Does not delete it on remote
            try FileManager.default.withTemporaryDirectory { local in
                let repo = try Repository(local: local, remote: remote)
                XCTAssertNoThrow(try repo.branch(on: "origin", named: "main"))
            }
        }
    }
}
