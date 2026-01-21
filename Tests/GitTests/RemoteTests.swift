import Foundation
import Git
import Testing

@Suite("Remote")
struct RemoteTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryRemotes() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let remotes = try repository.remotes
    #expect(remotes.count == 1)
    #expect(remotes.first?.name == "origin")
    #expect(remotes.first?.url == URL.repository)
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryRemoteNamed() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let remote = try repository.remote(named: "origin")
    #expect(remote.name == "origin")
    #expect(remote.url == URL.repository)
  }
}
