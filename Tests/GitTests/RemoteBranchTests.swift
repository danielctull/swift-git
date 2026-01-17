import Foundation
import Git
import Testing

@Suite("RemoteBranch")
struct RemoteBranchTests {

  @Test func repositoryRemoteBranches() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let remoteBranches = try Array(repo.remoteBranches)
      #expect(remoteBranches.count == 2)
      #expect(try remoteBranches.value(at: 0).id.description == "refs/remotes/origin/HEAD")
      #expect(try remoteBranches.value(at: 0).reference.description == "refs/remotes/origin/HEAD")
      #expect(try remoteBranches.value(at: 0).name.description == "origin/HEAD")
      #expect(try remoteBranches.value(at: 0).name.remote == "origin")
      #expect(try remoteBranches.value(at: 0).name.branch == "HEAD")
      #expect(try remoteBranches.value(at: 0).target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
      #expect(try remoteBranches.value(at: 1).id.description == "refs/remotes/origin/main")
      #expect(try remoteBranches.value(at: 1).reference.description == "refs/remotes/origin/main")
      #expect(try remoteBranches.value(at: 1).name.description == "origin/main")
      #expect(try remoteBranches.value(at: 1).name.remote == "origin")
      #expect(try remoteBranches.value(at: 1).name.branch == "main")
      #expect(try remoteBranches.value(at: 1).target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }

  @Test func repositoryRemoteBranchNamed() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let remoteBranch = try repo.branch(on: "origin", named: "main")
      #expect(remoteBranch.name.description == "origin/main")
      #expect(remoteBranch.id.description == "refs/remotes/origin/main")
      #expect(remoteBranch.reference.description == "refs/remotes/origin/main")
      #expect(remoteBranch.name.remote == "origin")
      #expect(remoteBranch.name.branch == "main")
      #expect(remoteBranch.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }

  @Test func delete() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let remoteBranch = try repo.branch(on: "origin", named: "main")
      try repo.delete(.remoteBranch(remoteBranch))
      #expect(throws: (any Error).self) {
        try repo.branch(on: "origin", named: "main")
      }

      // Does not delete it on remote
      try FileManager.default.withTemporaryDirectory { local in
        let repo = try Repository(local: local, remote: remote)
        #expect(throws: Never.self) {
          try repo.branch(on: "origin", named: "main")
        }
      }
    }
  }
}
