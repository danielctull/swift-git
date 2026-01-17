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

  @Test(.scratchDirectory)
  func clone() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    let repo = try Repository.clone(remote, to: .scratchDirectory)
    AssertEqualResolvingSymlinks(repo.workingDirectory, URL.scratchDirectory)
    try AssertEqualResolvingSymlinks(
      repo.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }
}
