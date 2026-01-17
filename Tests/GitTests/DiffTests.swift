import Foundation
import Git
import XCTest

final class DiffTests: XCTestCase {

  func testAddedFile() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let commits = try Array(repo.commits(sortedBy: .reverse))
      XCTAssertEqual(commits.count, 4)
      let first = try commits.value(at: 0)
      let second = try commits.value(at: 1)
      let diff = try repo.diff(from: first.tree, to: second.tree)
      XCTAssertEqual(diff.deltas.count, 1)
      let delta = try Array(diff.deltas).value(at: 0)
      XCTAssertEqual(delta.status, .added)
      XCTAssertEqual(delta.flags, [])

      XCTAssertNil(delta.from)

      let file = try XCTUnwrap(delta.to)
      XCTAssertEqual(file.flags, [.validID, .exists])
      XCTAssertEqual(file.size, 0)
      XCTAssertEqual(file.path, "file.text")
      XCTAssertEqual(
        file.id.description,
        "96c36b4c2da3a3b8472d437cea0497d38f125b04"
      )

      let object = try repo.object(for: file.id)
      guard case .blob(let blob) = object else {
        XCTFail("Expected blob")
        return
      }
      XCTAssertEqual(
        blob.id.description,
        "96c36b4c2da3a3b8472d437cea0497d38f125b04"
      )
      XCTAssertFalse(blob.isBinary)
      XCTAssertEqual(
        String(data: blob.data, encoding: .utf8),
        "A test file is made!"
      )
    }
  }

  func testAddedFileHunk() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let commits = try Array(repo.commits(sortedBy: .reverse))
      XCTAssertEqual(commits.count, 4)
      let first = try commits.value(at: 0)
      let second = try commits.value(at: 1)
      let diff = try repo.diff(from: first.tree, to: second.tree)
      let hunks = try diff.hunks
      XCTAssertEqual(hunks.count, 1)
      let hunk = try hunks.value(at: 0)

      let file = try XCTUnwrap(hunk.file)
      XCTAssertEqual(file.flags, [.notBinary, .validID, .exists, .validSize])
      XCTAssertEqual(file.size, 20)
      XCTAssertEqual(file.path, "file.text")
      XCTAssertEqual(
        file.id.description,
        "96c36b4c2da3a3b8472d437cea0497d38f125b04"
      )
      XCTAssertEqual(hunk.lines, 1...1)
    }
  }
}
