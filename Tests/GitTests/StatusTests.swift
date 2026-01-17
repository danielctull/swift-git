import Foundation
import Git
import Testing

@Suite("Status")
struct StatusTests {

  @Test func addFileToWorkingDirectory() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      #expect(try repo.status.count == 0)

      let path = UUID().uuidString
      let content = UUID().uuidString
      try Data(content.utf8).write(to: local.appending(path: path))

      let entries = try repo.status
      #expect(entries.count == 1)

      let entry = try XCTUnwrap(entries.first)
      #expect(entry.status == .workingTreeNew)
      XCTAssertNil(entry.headToIndex)

      let delta = try XCTUnwrap(entry.indexToWorkingDirectory)
      #expect(delta.status == .untracked)
      XCTAssertNil(delta.from)
      #expect(delta.flags == [])

      let file = try XCTUnwrap(delta.to)
      #expect(file.path == path)
      #expect(file.flags == [.exists, .validSize])
      #expect(file.size == UInt64(content.count))
      #expect(file.id.description == "0000000000000000000000000000000000000000")
    }
  }
}
