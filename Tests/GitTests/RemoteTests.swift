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
      XCTAssertEqual(remotes.count, 1)
      XCTAssertEqual(remotes.first?.name, "origin")
      XCTAssertEqual(remotes.first?.url, remoteURL)
    }
  }

  @Test func repositoryRemoteNamed() throws {
    let remoteURL = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remoteURL)
      let remote = try repo.remote(named: "origin")
      XCTAssertEqual(remote.name, "origin")
      XCTAssertEqual(remote.url, remoteURL)
    }
  }
}
