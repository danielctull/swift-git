import Foundation
import Git
import XCTest

@GitActor
final class IndexTests: XCTestCase {

  func testIndex() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let entries = try Array(repo.index.entries)
      XCTAssertEqual(entries.count, 2)

      do {
        let entry = try entries.value(at: 0)
        XCTAssertEqual(entry.objectID.description, "96c36b4c2da3a3b8472d437cea0497d38f125b04")
      }

      do {
        let entry = try entries.value(at: 1)
        XCTAssertEqual(entry.objectID.description, "e5c0a8638a0d8dfa0c733f9d666c511f7e1f9a96")
      }
    }
  }
}
