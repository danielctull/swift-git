import Foundation
import Git
import Testing

@Suite("Index")
struct IndexTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func index() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let entries = try Array(repository.index.entries)
    #expect(entries.count == 2)

    #expect(
      Set(entries.map(\.objectID.description)) == [
        "96c36b4c2da3a3b8472d437cea0497d38f125b04",
        "e5c0a8638a0d8dfa0c733f9d666c511f7e1f9a96",
      ]
    )
  }
}
