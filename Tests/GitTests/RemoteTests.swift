
import Foundation
import Git
import XCTest

@GitActor
final class RemoteTests: XCTestCase {

    func testRepositoryRemote() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remote = try repo.remote(for: "origin")
            XCTAssertEqual(remote.id, "origin")
            XCTAssertEqual(remote.name, "origin")
//            XCTAssertEqual(remote.url, local)
        }
    }
}
