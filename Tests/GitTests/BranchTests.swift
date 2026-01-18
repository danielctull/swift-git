import Foundation
import Git
import Testing

@Suite("Branch")
struct BranchTests {

  @Test func repositoryBranches() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let branches = try Array(repo.branches)
      #expect(branches.count == 1)
      let branch = try #require(branches.first)
      #expect(branch.name == "main")
      #expect(branch.id.description == "refs/heads/main")
      #expect(branch.reference.description == "refs/heads/main")
      #expect(
        branch.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
    }
  }

  @Test func repositoryCreateBranchNamed() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let commits = try Array(repo.commits(for: .branch(main)))
      let commit = try #require(commits.first)
      let main2 = try repo.createBranch(named: "main2", at: commit)
      #expect(main2.name == "main2")
      #expect(main2.id.description == "refs/heads/main2")
      #expect(main2.reference.description == "refs/heads/main2")
      #expect(
        main2.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
    }
  }

  @Test func repositoryBranchNamed() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let branch = try repo.branch(named: "main")
      #expect(branch.name == "main")
      #expect(branch.id.description == "refs/heads/main")
      #expect(branch.reference.description == "refs/heads/main")
      #expect(
        branch.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
    }
  }

  @Test func branchMove() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let branch = try repo.branch(named: "main")
      do {
        let moved = try branch.move(to: "moved")
        #expect(moved.name == "moved")
        #expect(moved.id.description == "refs/heads/moved")
        #expect(moved.reference.description == "refs/heads/moved")
        #expect(
          moved.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
        )
      }
      do {
        let moved = try repo.branch(named: "moved")
        #expect(moved.name == "moved")
        #expect(moved.id.description == "refs/heads/moved")
        #expect(moved.reference.description == "refs/heads/moved")
        #expect(
          moved.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
        )
      }
      #expect(throws: (any Error).self) { try repo.branch(named: "main") }
    }
  }

  @Test func delete() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let commits = try Array(repo.commits(for: .branch(main)))
      let commit = try #require(commits.first)
      let main2 = try repo.createBranch(named: "main2", at: commit)
      #expect(throws: Never.self) { try repo.branch(named: "main2") }
      try repo.delete(.branch(main2))
      #expect(throws: (any Error).self) { try repo.branch(named: "main2") }
    }
  }

  @Test func upstream() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let remoteBranch = try main.upstream
      #expect(remoteBranch.id.description == "refs/remotes/origin/main")
      #expect(remoteBranch.reference.description == "refs/remotes/origin/main")
      #expect(remoteBranch.name.description == "origin/main")
      #expect(remoteBranch.name.remote == "origin")
      #expect(remoteBranch.name.branch == "main")
      #expect(
        remoteBranch.target.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
    }
  }

  @Test func setUpstream() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let main = try repo.branch(named: "main")
      let commit = try #require(Array(repo.commits(for: .branch(main))).first)

      let main2 = try repo.createBranch(named: "main2", at: commit)
      #expect(throws: (any Error).self) { try main2.upstream }

      try main2.setUpstream(main.upstream)
      let remoteBranch = try main.upstream
      #expect(remoteBranch.id.description == "refs/remotes/origin/main")
      #expect(remoteBranch.reference.description == "refs/remotes/origin/main")
      #expect(remoteBranch.name.description == "origin/main")
      #expect(remoteBranch.name.remote == "origin")
      #expect(remoteBranch.name.branch == "main")
      #expect(
        remoteBranch.target.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
    }
  }
}
