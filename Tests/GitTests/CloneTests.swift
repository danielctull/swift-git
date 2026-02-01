import Foundation
import Git
import Testing

private func assertPathsEqual(
  _ expression1: @autoclosure () throws -> URL?,
  _ expression2: @autoclosure () throws -> URL?,
  file: StaticString = #filePath,
  line: UInt = #line
) rethrows {
  let path1 = try expression1()?.resolvingSymlinksInPath().standardized.path
  let path2 = try expression2()?.resolvingSymlinksInPath().standardized.path
  // Normalize trailing slashes for comparison
  let normalized1 = path1.map { $0.hasSuffix("/") ? String($0.dropLast()) : $0 }
  let normalized2 = path2.map { $0.hasSuffix("/") ? String($0.dropLast()) : $0 }
  #expect(normalized1 == normalized2)
}

@Suite("Clone")
struct CloneTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func clone() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    assertPathsEqual(
      repository.workingDirectory,
      URL.scratchDirectory
    )
    try assertPathsEqual(
      repository.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }
}
