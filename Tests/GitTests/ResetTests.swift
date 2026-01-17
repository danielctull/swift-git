import Foundation
import Git
import XCTest

final class ResetTests: XCTestCase {

  func testResetSoft() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)

      XCTAssertEqual(
        try repo.current.id.description,
        "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.current), operation: .soft)
      XCTAssertEqual(
        try repo.current.id.description,
        "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.previous), operation: .soft)
      XCTAssertEqual(
        try repo.current.id.description,
        "c8b08c2ed176eaaf7cea877f774319a27684870a"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.previous), operation: .soft)
      XCTAssertEqual(
        try repo.current.id.description,
        "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      XCTAssertEqual(try repo.status.count, 2)

      let addition = try XCTUnwrap(
        repo.status.first(where: { $0.status == .indexNew })
      )
      XCTAssertEqual(addition.headToIndex?.to?.path, "file.txt")

      let deletion = try XCTUnwrap(
        repo.status.first(where: { $0.status == .indexDeleted })
      )
      XCTAssertEqual(deletion.headToIndex?.from?.path, "file.text")
    }
  }

  func testResetMixed() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)

      XCTAssertEqual(
        try repo.current.id.description,
        "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.current), operation: .mixed)
      XCTAssertEqual(
        try repo.current.id.description,
        "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.previous), operation: .mixed)
      XCTAssertEqual(
        try repo.current.id.description,
        "c8b08c2ed176eaaf7cea877f774319a27684870a"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.previous), operation: .mixed)
      XCTAssertEqual(
        try repo.current.id.description,
        "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      XCTAssertEqual(try repo.status.count, 2)

      let addition = try XCTUnwrap(
        repo.status.first(where: { $0.status == .workingTreeNew })
      )
      XCTAssertEqual(addition.indexToWorkingDirectory?.to?.path, "file.txt")

      let deletion = try XCTUnwrap(
        repo.status.first(where: { $0.status == .workingTreeDeleted })
      )
      XCTAssertEqual(deletion.indexToWorkingDirectory?.from?.path, "file.text")
    }
  }

  func testResetHard() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)

      XCTAssertEqual(
        try repo.current.id.description,
        "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.current), operation: .hard)
      XCTAssertEqual(
        try repo.current.id.description,
        "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.previous), operation: .hard)
      XCTAssertEqual(
        try repo.current.id.description,
        "c8b08c2ed176eaaf7cea877f774319a27684870a"
      )
      XCTAssertEqual(try repo.status.count, 0)

      try repo.reset(to: .commit(repo.previous), operation: .hard)
      XCTAssertEqual(
        try repo.current.id.description,
        "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      XCTAssertEqual(try repo.status.count, 0)
    }
  }
}

extension Repository {

  fileprivate var current: Commit {
    get throws {
      try Array(XCTUnwrap(commits)).value(at: 0)
    }
  }

  fileprivate var previous: Commit {
    get throws {
      try Array(XCTUnwrap(commits)).value(at: 1)
    }
  }
}
