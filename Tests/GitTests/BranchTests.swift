import Foundation
import Git
import XCTest

@GitActor
final class BranchTests: XCTestCase {

  func testRepositoryBranches() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let branches = try Array(repo.branches)
      XCTAssertEqual(branches.count, 1)
      let branch = try XCTUnwrap(branches.first)
      XCTAssertEqual(branch.name, "main")
      XCTAssertEqual(branch.id.description, "refs/heads/main")
      XCTAssertEqual(branch.reference.description, "refs/heads/main")
      XCTAssertEqual(branch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }

  func testRepositoryCreateBranchNamed() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let commits = try Array(repo.commits(for: .branch(main)))
      let commit = try XCTUnwrap(commits.first)
      let main2 = try repo.createBranch(named: "main2", at: commit)
      XCTAssertEqual(main2.name, "main2")
      XCTAssertEqual(main2.id.description, "refs/heads/main2")
      XCTAssertEqual(main2.reference.description, "refs/heads/main2")
      XCTAssertEqual(main2.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }

  func testRepositoryBranchNamed() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let branch = try repo.branch(named: "main")
      XCTAssertEqual(branch.name, "main")
      XCTAssertEqual(branch.id.description, "refs/heads/main")
      XCTAssertEqual(branch.reference.description, "refs/heads/main")
      XCTAssertEqual(branch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }

  func testBranchMove() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let branch = try repo.branch(named: "main")
      do {
        let moved = try branch.move(to: "moved")
        XCTAssertEqual(moved.name, "moved")
        XCTAssertEqual(moved.id.description, "refs/heads/moved")
        XCTAssertEqual(moved.reference.description, "refs/heads/moved")
        XCTAssertEqual(moved.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
      }
      do {
        let moved = try repo.branch(named: "moved")
        XCTAssertEqual(moved.name, "moved")
        XCTAssertEqual(moved.id.description, "refs/heads/moved")
        XCTAssertEqual(moved.reference.description, "refs/heads/moved")
        XCTAssertEqual(moved.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
      }
      XCTAssertThrowsError(try repo.branch(named: "main"))
    }
  }

  func testDelete() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let commits = try Array(repo.commits(for: .branch(main)))
      let commit = try XCTUnwrap(commits.first)
      let main2 = try repo.createBranch(named: "main2", at: commit)
      XCTAssertNoThrow(try repo.branch(named: "main2"))
      try repo.delete(.branch(main2))
      XCTAssertThrowsError(try repo.branch(named: "main2"))
    }
  }

  func testUpstream() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let remoteBranch = try main.upstream
      XCTAssertEqual(remoteBranch.id.description, "refs/remotes/origin/main")
      XCTAssertEqual(remoteBranch.reference.description, "refs/remotes/origin/main")
      XCTAssertEqual(remoteBranch.name.description, "origin/main")
      XCTAssertEqual(remoteBranch.name.remote, "origin")
      XCTAssertEqual(remoteBranch.name.branch, "main")
      XCTAssertEqual(remoteBranch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }

  func testSetUpstream() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let commit = try XCTUnwrap(Array(repo.commits(for: .branch(main))).first)

      let main2 = try repo.createBranch(named: "main2", at: commit)
      XCTAssertThrowsError(try main2.upstream)

      try main2.setUpstream(main.upstream)
      let remoteBranch = try main.upstream
      XCTAssertEqual(remoteBranch.id.description, "refs/remotes/origin/main")
      XCTAssertEqual(remoteBranch.reference.description, "refs/remotes/origin/main")
      XCTAssertEqual(remoteBranch.name.description, "origin/main")
      XCTAssertEqual(remoteBranch.name.remote, "origin")
      XCTAssertEqual(remoteBranch.name.branch, "main")
      XCTAssertEqual(remoteBranch.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }
}
