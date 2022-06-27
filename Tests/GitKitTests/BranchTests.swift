
import Foundation
import GitKit
import XCTest

final class BranchTests: XCTestCase {

    func testRepositoryBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branches = try repo.branches
            XCTAssertEqual(branches.count, 1)
            let branch = try XCTUnwrap(branches.first)
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.id, "refs/heads/main")
            XCTAssertEqual(branch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }

    func testRepositoryCreateBranchNamed() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let main = try repo.branch(named: "main")
            let commits = try repo.commits(for: .branch(main))
            let commit = try XCTUnwrap(commits.first)
            let main2 = try repo.createBranch(named: "main2", at: commit)
            XCTAssertEqual(main2.name, "main2")
            XCTAssertEqual(main2.id, "refs/heads/main2")
            XCTAssertEqual(main2.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }

    func testRepositoryBranchNamed() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branch = try repo.branch(named: "main")
            XCTAssertEqual(branch.name, "main")
            XCTAssertEqual(branch.id, "refs/heads/main")
            XCTAssertEqual(branch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }

    func testBranchDelete() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let main = try repo.branch(named: "main")
            let commits = try repo.commits(for: .branch(main))
            let commit = try XCTUnwrap(commits.first)
            let main2 = try repo.createBranch(named: "main2", at: commit)
            XCTAssertNoThrow(try repo.branch(named: "main2"))
            try repo.delete(main2)
            XCTAssertThrowsError(try repo.branch(named: "main2"))
        }
    }
}
