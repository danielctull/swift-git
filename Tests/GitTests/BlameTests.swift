import Foundation
import Git
import Testing

@Suite("Blame")
struct BlameTests {

  @Test func blame() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository.clone(remote, to: local)
      let blame = try repo.blame(for: "file.txt")
      let hunks = blame.hunks
      #expect(hunks.count == 1)
      let hunk = try Array(hunks).value(at: 0)
      #expect(
        hunk.commitID.description == "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      #expect(hunk.lines.lowerBound == 1)
      #expect(hunk.lines.upperBound == 1)
      #expect(hunk.signature.date == Date(timeIntervalSince1970: 1_595_676_911))
      #expect(hunk.signature.email == "dt@danieltull.co.uk")
      #expect(hunk.signature.name == "Daniel Tull")
      #expect(hunk.path == "file.text")
      #expect(try blame.hunk(for: 1) == hunk)
    }
  }
}
