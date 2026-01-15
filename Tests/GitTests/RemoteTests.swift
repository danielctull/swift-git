import Foundation
import Git
import XCTest

@GitActor
final class RemoteTests: XCTestCase {

  func testRepositoryRemotes() throws {
    let remoteURL = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remoteURL)
      let remotes = try repo.remotes
      XCTAssertEqual(remotes.count, 1)
      XCTAssertEqual(remotes.first?.name, "origin")
      XCTAssertEqual(remotes.first?.url, remoteURL)
    }
  }

  func testRepositoryRemoteNamed() throws {
    let remoteURL = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remoteURL)
      let remote = try repo.remote(named: "origin")
      XCTAssertEqual(remote.name, "origin")
      XCTAssertEqual(remote.url, remoteURL)
    }
  }
}
