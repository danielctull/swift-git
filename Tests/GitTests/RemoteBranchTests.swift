import Foundation
import Git
import Testing

@Suite("RemoteBranch")
struct RemoteBranchTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryRemoteBranches() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let remoteBranches = try Array(repository.remoteBranches)
    #expect(remoteBranches.count == 2)
    #expect(
      try remoteBranches.value(at: 0).id.description
        == "refs/remotes/origin/HEAD"
    )
    #expect(
      try remoteBranches.value(at: 0).reference.description
        == "refs/remotes/origin/HEAD"
    )
    #expect(try remoteBranches.value(at: 0).name.description == "origin/HEAD")
    #expect(try remoteBranches.value(at: 0).name.remote == "origin")
    #expect(try remoteBranches.value(at: 0).name.branch == "HEAD")
    #expect(
      try remoteBranches.value(at: 0).target.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(
      try remoteBranches.value(at: 1).id.description
        == "refs/remotes/origin/main"
    )
    #expect(
      try remoteBranches.value(at: 1).reference.description
        == "refs/remotes/origin/main"
    )
    #expect(try remoteBranches.value(at: 1).name.description == "origin/main")
    #expect(try remoteBranches.value(at: 1).name.remote == "origin")
    #expect(try remoteBranches.value(at: 1).name.branch == "main")
    #expect(
      try remoteBranches.value(at: 1).target.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryRemoteBranchNamed() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let remoteBranch = try repository.branch(on: "origin", named: "main")
    #expect(remoteBranch.name.description == "origin/main")
    #expect(remoteBranch.id.description == "refs/remotes/origin/main")
    #expect(remoteBranch.reference.description == "refs/remotes/origin/main")
    #expect(remoteBranch.name.remote == "origin")
    #expect(remoteBranch.name.branch == "main")
    #expect(
      remoteBranch.target.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func delete() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let remoteBranch = try repository.branch(on: "origin", named: "main")
    try repository.delete(.remoteBranch(remoteBranch))
    #expect(throws: (any Error).self) {
      try repository.branch(on: "origin", named: "main")
    }

    // Does not delete it on remote
    try ScratchDirectory(.random) {
      let repository = try Repository.clone(.repository, to: .scratchDirectory)
      #expect(throws: Never.self) {
        try repository.branch(on: "origin", named: "main")
      }
    }
  }
}
