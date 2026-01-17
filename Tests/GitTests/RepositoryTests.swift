import Foundation
import Git
import Testing

private func AssertEqualResolvingSymlinks(
  _ expression1: @autoclosure () throws -> URL?,
  _ expression2: @autoclosure () throws -> URL?,
  file: StaticString = #filePath,
  line: UInt = #line
) rethrows {
  #expect(try expression1()?.resolvingSymlinksInPath() == expression2()?.resolvingSymlinksInPath())
}

@Suite("Repository")
struct RepositoryTests {

  @Test func clone() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      AssertEqualResolvingSymlinks(repo.workingDirectory, local)
      try AssertEqualResolvingSymlinks(
        repo.gitDirectory,
        local.appending(path: ".git")
      )
    }
  }

  @Test func create() throws {
    try FileManager.default.withTemporaryDirectory { url in
      let repo = try Repository(url: url)
      AssertEqualResolvingSymlinks(repo.workingDirectory, url)
      try AssertEqualResolvingSymlinks(
        repo.gitDirectory,
        url.appending(path: ".git")
      )
    }
  }

  @Test func createBare() throws {
    try FileManager.default.withTemporaryDirectory { url in
      let bare = try Repository(url: url, options: .create(isBare: true))
      #expect(bare.workingDirectory == nil)
      try AssertEqualResolvingSymlinks(bare.gitDirectory, url)
    }
  }

  @Test func createNotBare() throws {
    try FileManager.default.withTemporaryDirectory { url in
      let repo = try Repository(url: url, options: .create(isBare: false))
      AssertEqualResolvingSymlinks(repo.workingDirectory, url)
      try AssertEqualResolvingSymlinks(
        repo.gitDirectory,
        url.appending(path: ".git")
      )
    }
  }

  @Test func open() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      #expect(throws: Never.self) {
        try Repository(local: local, remote: remote)
      }
      let repo = try Repository(url: local, options: .open)
      AssertEqualResolvingSymlinks(repo.workingDirectory, local)
      try AssertEqualResolvingSymlinks(
        repo.gitDirectory,
        local.appending(path: ".git")
      )
    }
  }
}
