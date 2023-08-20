
import Foundation
import Git
import XCTest

@GitActor
final class RemoteTests: XCTestCase {

    func testRepositoryRemote() throws {
        let remoteURL = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remoteURL)
            let remote = try repo.remote(named: "origin")
            XCTAssertEqual(remote.name, "origin")
            XCTAssertEqual(remote.url, remoteURL)
        }
    }
}
