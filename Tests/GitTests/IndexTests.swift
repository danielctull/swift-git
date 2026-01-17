import Foundation
import Git
import Testing

@Suite("Index")
struct IndexTests {

  @Test(.scratchDirectory(.random))
  func index() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    let repo = try Repository.clone(remote, to: .scratchDirectory)
    let entries = try Array(repo.index.entries)
    #expect(entries.count == 2)

    do {
      let entry = try entries.value(at: 0)
      #expect(
        entry.objectID.description
          == "96c36b4c2da3a3b8472d437cea0497d38f125b04"
      )
    }

    do {
      let entry = try entries.value(at: 1)
      #expect(
        entry.objectID.description
          == "e5c0a8638a0d8dfa0c733f9d666c511f7e1f9a96"
      )
    }
  }
}
