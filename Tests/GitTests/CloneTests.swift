import Foundation
import Git
import Testing
import XCTest

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

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func clone() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    AssertEqualResolvingSymlinks(
      repository.workingDirectory,
      URL.scratchDirectory
    )
    try AssertEqualResolvingSymlinks(
      repository.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }
}
