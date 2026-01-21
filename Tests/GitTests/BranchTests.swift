import Foundation
import Git
import Testing

@Suite("Branch")
struct BranchTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryBranches() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let branches = try Array(repository.branches)
    #expect(branches.count == 1)
    let branch = try #require(branches.first)
    #expect(branch.name == "main")
    #expect(branch.id.description == "refs/heads/main")
    #expect(branch.reference.description == "refs/heads/main")
    #expect(
      branch.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryCreateBranchNamed() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let main = try repository.branch(named: "main")
    let commits = try Array(repository.commits(for: .branch(main)))
    let commit = try #require(commits.first)
    let main2 = try repository.createBranch(named: "main2", at: commit)
    #expect(main2.name == "main2")
    #expect(main2.id.description == "refs/heads/main2")
    #expect(main2.reference.description == "refs/heads/main2")
    #expect(
      main2.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryBranchNamed() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let branch = try repository.branch(named: "main")
    #expect(branch.name == "main")
    #expect(branch.id.description == "refs/heads/main")
    #expect(branch.reference.description == "refs/heads/main")
    #expect(
      branch.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func branchMove() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let branch = try repository.branch(named: "main")
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
      let moved = try repository.branch(named: "moved")
      #expect(moved.name == "moved")
      #expect(moved.id.description == "refs/heads/moved")
      #expect(moved.reference.description == "refs/heads/moved")
      #expect(
        moved.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
    }
    #expect(throws: (any Error).self) { try repository.branch(named: "main") }
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func delete() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let main = try repository.branch(named: "main")
    let commits = try Array(repository.commits(for: .branch(main)))
    let commit = try #require(commits.first)
    let main2 = try repository.createBranch(named: "main2", at: commit)
    #expect(throws: Never.self) { try repository.branch(named: "main2") }
    try repository.delete(.branch(main2))
    #expect(throws: (any Error).self) { try repository.branch(named: "main2") }
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func upstream() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let main = try repository.branch(named: "main")
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

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func setUpstream() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let main = try repository.branch(named: "main")
    let commits = try repository.commits(for: .branch(main))
    let commit = try #require(Array(commits).first)

    let main2 = try repository.createBranch(named: "main2", at: commit)
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
