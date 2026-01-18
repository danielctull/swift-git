import Foundation
import Git
import Testing

@Suite("Reset")
struct ResetTests {

  @Test func resetSoft() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)

      #expect(
        try repo.current.id.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.current), operation: .soft)
      #expect(
        try repo.current.id.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.previous), operation: .soft)
      #expect(
        try repo.current.id.description
          == "c8b08c2ed176eaaf7cea877f774319a27684870a"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.previous), operation: .soft)
      #expect(
        try repo.current.id.description
          == "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      #expect(try repo.status.count == 2)

      let addition = try #require(
        repo.status.first(where: { $0.status == .indexNew })
      )
      #expect(addition.headToIndex?.to?.path == "file.txt")

      let deletion = try #require(
        repo.status.first(where: { $0.status == .indexDeleted })
      )
      #expect(deletion.headToIndex?.from?.path == "file.text")
    }
  }

  @Test func resetMixed() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)

      #expect(
        try repo.current.id.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.current), operation: .mixed)
      #expect(
        try repo.current.id.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.previous), operation: .mixed)
      #expect(
        try repo.current.id.description
          == "c8b08c2ed176eaaf7cea877f774319a27684870a"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.previous), operation: .mixed)
      #expect(
        try repo.current.id.description
          == "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      #expect(try repo.status.count == 2)

      let addition = try #require(
        repo.status.first(where: { $0.status == .workingTreeNew })
      )
      #expect(addition.indexToWorkingDirectory?.to?.path == "file.txt")

      let deletion = try #require(
        repo.status.first(where: { $0.status == .workingTreeDeleted })
      )
      #expect(deletion.indexToWorkingDirectory?.from?.path == "file.text")
    }
  }

  @Test func resetHard() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)

      #expect(
        try repo.current.id.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.current), operation: .hard)
      #expect(
        try repo.current.id.description
          == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.previous), operation: .hard)
      #expect(
        try repo.current.id.description
          == "c8b08c2ed176eaaf7cea877f774319a27684870a"
      )
      #expect(try repo.status.count == 0)

      try repo.reset(to: .commit(repo.previous), operation: .hard)
      #expect(
        try repo.current.id.description
          == "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      #expect(try repo.status.count == 0)
    }
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
