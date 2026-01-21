import Foundation
import Git
import Testing

@Suite("Reset")
struct ResetTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func resetSoft() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    #expect(
      try repository.current.id.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.current), operation: .soft)
    #expect(
      try repository.current.id.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.previous), operation: .soft)
    #expect(
      try repository.current.id.description
        == "c8b08c2ed176eaaf7cea877f774319a27684870a"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.previous), operation: .soft)
    #expect(
      try repository.current.id.description
        == "41c143541c9d917db83ce4e920084edbf2a4177e"
    )
    #expect(try repository.status.count == 2)

    let addition = try #require(
      repository.status.first(where: { $0.status == .indexNew })
    )
    #expect(addition.headToIndex?.to?.path == "file.txt")

    let deletion = try #require(
      repository.status.first(where: { $0.status == .indexDeleted })
    )
    #expect(deletion.headToIndex?.from?.path == "file.text")
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func resetMixed() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    #expect(
      try repository.current.id.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.current), operation: .mixed)
    #expect(
      try repository.current.id.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.previous), operation: .mixed)
    #expect(
      try repository.current.id.description
        == "c8b08c2ed176eaaf7cea877f774319a27684870a"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.previous), operation: .mixed)
    #expect(
      try repository.current.id.description
        == "41c143541c9d917db83ce4e920084edbf2a4177e"
    )
    #expect(try repository.status.count == 2)

    let addition = try #require(
      repository.status.first(where: { $0.status == .workingTreeNew })
    )
    #expect(addition.indexToWorkingDirectory?.to?.path == "file.txt")

    let deletion = try #require(
      repository.status.first(where: { $0.status == .workingTreeDeleted })
    )
    #expect(deletion.indexToWorkingDirectory?.from?.path == "file.text")
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func resetHard() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    #expect(
      try repository.current.id.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.current), operation: .hard)
    #expect(
      try repository.current.id.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.previous), operation: .hard)
    #expect(
      try repository.current.id.description
        == "c8b08c2ed176eaaf7cea877f774319a27684870a"
    )
    #expect(try repository.status.count == 0)

    try repository.reset(to: .commit(repository.previous), operation: .hard)
    #expect(
      try repository.current.id.description
        == "41c143541c9d917db83ce4e920084edbf2a4177e"
    )
    #expect(try repository.status.count == 0)
  }
}

extension Repository {

  fileprivate var current: Commit {
    get throws {
      try Array(commits).value(at: 0)
    }
  }

  fileprivate var previous: Commit {
    get throws {
      try Array(commits).value(at: 1)
    }
  }
}
