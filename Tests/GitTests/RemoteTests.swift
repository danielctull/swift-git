import Foundation
import Git
import Testing

@Suite("Remote")
struct RemoteTests {

  @Test func repositoryRemotes() throws {
    let remoteURL = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remoteURL)
      let remotes = try repo.remotes
      #expect(remotes.count == 1)
      #expect(remotes.first?.name == "origin")
      #expect(remotes.first?.url == remoteURL)
    }
  }

  @Test func repositoryRemoteNamed() throws {
    let remoteURL = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remoteURL)
      let remote = try repo.remote(named: "origin")
      #expect(remote.name == "origin")
      #expect(remote.url == remoteURL)
    }
  }
}
