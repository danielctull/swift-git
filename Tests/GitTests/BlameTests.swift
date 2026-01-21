import Foundation
import Git
import Testing

@Suite("Blame")
struct BlameTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func blame() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let blame = try repository.blame(for: "file.txt")
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
