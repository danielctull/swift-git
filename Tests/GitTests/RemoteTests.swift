import Foundation
import Git
import Testing

@Suite("Remote")
struct RemoteTests {

  @Test(.scratchDirectory)
  func repositoryRemotes() throws {
    let remoteURL = try Bundle.module.url(forRepository: "Test.git")
    let repo = try Repository.clone(remoteURL, to: .scratchDirectory)
    let remotes = try repo.remotes
    #expect(remotes.count == 1)
    #expect(remotes.first?.name == "origin")
    #expect(remotes.first?.url == remoteURL)
  }

  @Test(.scratchDirectory)
  func repositoryRemoteNamed() throws {
    let remoteURL = try Bundle.module.url(forRepository: "Test.git")
    let repo = try Repository.clone(remoteURL, to: .scratchDirectory)
    let remote = try repo.remote(named: "origin")
    #expect(remote.name == "origin")
    #expect(remote.url == remoteURL)
  }
}
