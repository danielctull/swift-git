
import Foundation
import GitKit
import XCTest

final class RemoteTests: XCTestCase {

    func testRepositoryRemote() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remote = try repo.remote(named: "origin")
            XCTAssertEqual(remote.id, "origin")
            XCTAssertEqual(remote.name, "origin")
//            XCTAssertEqual(remote.url, local)
        }
    }
}
