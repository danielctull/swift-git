import Foundation
import Git
import Testing

private func AssertEqualResolvingSymlinks(
  _ expression1: @autoclosure () throws -> URL?,
  _ expression2: @autoclosure () throws -> URL?,
  file: StaticString = #filePath,
  line: UInt = #line
) rethrows {
  #expect(
    try expression1()?.resolvingSymlinksInPath()
      == expression2()?.resolvingSymlinksInPath()
  )
}

@Suite("Clone")
struct CloneTests {

  @Test func clone() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository.clone(remote, to: local)
      AssertEqualResolvingSymlinks(repo.workingDirectory, local)
      try AssertEqualResolvingSymlinks(
        repo.gitDirectory,
        local.appending(path: ".git")
      )
    }
  }
}
