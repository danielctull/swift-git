import Foundation
import Git
import Testing

@Suite("Status")
struct StatusTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func addFileToWorkingDirectory() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    #expect(try repository.status.count == 0)

    let path = UUID().uuidString
    let content = UUID().uuidString
    try Data(content.utf8).write(to: URL.scratchDirectory.appending(path: path))

    let entries = try repository.status
    #expect(entries.count == 1)

    let entry = try #require(entries.first)
    #expect(entry.status == .workingTreeNew)
    #expect(entry.headToIndex == nil)

    let delta = try #require(entry.indexToWorkingDirectory)
    #expect(delta.status == .untracked)
    #expect(delta.from == nil)
    #expect(delta.flags == [])

    let file = try #require(delta.to)
    #expect(file.path == path)
    #expect(file.flags == [.exists, .validSize])
    #expect(file.size == UInt64(content.count))
    #expect(file.id.description == "0000000000000000000000000000000000000000")
  }
}
