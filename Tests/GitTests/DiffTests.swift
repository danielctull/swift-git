import Foundation
import Git
import Testing

@Suite("Diff")
struct DiffTests {

  @Test func addedFile() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let commits = try Array(repo.commits(sortedBy: .reverse))
      #expect(commits.count == 4)
      let first = try commits.value(at: 0)
      let second = try commits.value(at: 1)
      let diff = try repo.diff(from: first.tree, to: second.tree)
      #expect(diff.deltas.count == 1)
      let delta = try Array(diff.deltas).value(at: 0)
      #expect(delta.status == .added)
      #expect(delta.flags == [])

      XCTAssertNil(delta.from)

      let file = try #require(delta.to)
      #expect(file.flags == [.validID, .exists])
      #expect(file.size == 0)
      #expect(file.path == "file.text")
      #expect(file.id.description == "96c36b4c2da3a3b8472d437cea0497d38f125b04")

      let object = try repo.object(for: file.id)
      guard case .blob(let blob) = object else {
        XCTFail("Expected blob")
        return
      }
      #expect(blob.id.description == "96c36b4c2da3a3b8472d437cea0497d38f125b04")
      XCTAssertFalse(blob.isBinary)
      #expect(String(data: blob.data, encoding: .utf8) == "A test file is made!")
    }
  }

  @Test func addedFileHunk() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let commits = try Array(repo.commits(sortedBy: .reverse))
      #expect(commits.count == 4)
      let first = try commits.value(at: 0)
      let second = try commits.value(at: 1)
      let diff = try repo.diff(from: first.tree, to: second.tree)
      let hunks = try diff.hunks
      #expect(hunks.count == 1)
      let hunk = try hunks.value(at: 0)

      let file = try #require(hunk.file)
      #expect(file.flags == [.notBinary, .validID, .exists, .validSize])
      #expect(file.size == 20)
      #expect(file.path == "file.text")
      #expect(file.id.description == "96c36b4c2da3a3b8472d437cea0497d38f125b04")
      #expect(hunk.lines == 1...1)
    }
  }
}
