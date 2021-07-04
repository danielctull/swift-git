
import Foundation
import Git
import XCTest

@GitActor
final class StatusTests: XCTestCase {

    func testAddFileToWorkingDirectory() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            XCTAssertEqual(try repo.status.count, 0)

            let path = UUID().uuidString
            let content = UUID().uuidString
            try Data(content.utf8).write(to: local.appending(path: path))

            let entries = try repo.status
            XCTAssertEqual(entries.count, 1)

            let entry = try XCTUnwrap(entries.first)
            XCTAssertEqual(entry.status, .workingTreeNew)
            XCTAssertNil(entry.headToIndex)

            let delta = try XCTUnwrap(entry.indexToWorkingDirectory)
            XCTAssertEqual(delta.status, .untracked)
            XCTAssertNil(delta.from)
            XCTAssertEqual(delta.flags, [])

            let file = try XCTUnwrap(delta.to)
            XCTAssertEqual(file.path, path)
//            XCTAssertEqual(file.flags, [.exists, .validSize])
            XCTAssertEqual(file.size, UInt64(content.count))
            XCTAssertEqual(file.id.description, "0000000000000000000000000000000000000000")
        }
    }
}
