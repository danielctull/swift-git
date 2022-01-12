
import Foundation
import GitKit
import XCTest

final class RemoteTests: XCTestCase {

    func testRepositoryRemote() async throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try await FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remote = try await repo.remote(for: "origin")
            XCTAssertEqual(remote.id, "origin")
            XCTAssertEqual(remote.name, "origin")
//            XCTAssertEqual(remote.url, local)
        }
    }
}
