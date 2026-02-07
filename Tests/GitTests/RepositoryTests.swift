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

@Suite("Repository")
struct RepositoryTests {

  @Test(.scratchDirectory(.random))
  func create() throws {
    let repository = try Repository.create(.scratchDirectory)
    assertPathsEqual(repository.workingDirectory, .scratchDirectory)
    try assertPathsEqual(
      repository.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }

  @Test(.scratchDirectory(.random))
  func createBare() throws {
    let bare = try Repository.create(.scratchDirectory, isBare: true)
    #expect(bare.workingDirectory == nil)
    try assertPathsEqual(bare.gitDirectory, .scratchDirectory)
  }

  @Test(.scratchDirectory(.random))
  func createNotBare() throws {
    let repository = try Repository.create(.scratchDirectory, isBare: false)
    assertPathsEqual(repository.workingDirectory, .scratchDirectory)
    try assertPathsEqual(
      repository.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func open() throws {
    #expect(throws: Never.self) {
      try Repository.clone(.repository, to: .scratchDirectory)
    }
    let repository = try Repository.open(URL.scratchDirectory)
    assertPathsEqual(repository.workingDirectory, .scratchDirectory)
    try assertPathsEqual(
      repository.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }
}
