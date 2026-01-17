import Foundation
import Git
import Testing

@Suite("Remote")
struct RemoteTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryRemotes() throws {
    let repo = try Repository.clone(.repository, to: .scratchDirectory)
    let remotes = try repo.remotes
    #expect(remotes.count == 1)
    #expect(remotes.first?.name == "origin")
    #expect(remotes.first?.url == URL.repository)
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryRemoteNamed() throws {
    let repo = try Repository.clone(.repository, to: .scratchDirectory)
    let remote = try repo.remote(named: "origin")
    #expect(remote.name == "origin")
    #expect(remote.url == URL.repository)
  }
}
