import Foundation
import Git
import Testing

private func assertEqualResolvingSymlinks(
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

@Suite("Repository")
struct RepositoryTests {

  @Test(.scratchDirectory(.random))
  func create() throws {
    let repository = try Repository.create(.scratchDirectory)
    assertEqualResolvingSymlinks(repository.workingDirectory, .scratchDirectory)
    try assertEqualResolvingSymlinks(
      repository.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }

  @Test(.scratchDirectory(.random))
  func createBare() throws {
    let bare = try Repository.create(.scratchDirectory, isBare: true)
    #expect(bare.workingDirectory == nil)
    try assertEqualResolvingSymlinks(bare.gitDirectory, .scratchDirectory)
  }

  @Test(.scratchDirectory(.random))
  func createNotBare() throws {
    let repository = try Repository.create(.scratchDirectory, isBare: false)
    assertEqualResolvingSymlinks(repository.workingDirectory, .scratchDirectory)
    try assertEqualResolvingSymlinks(
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
    assertEqualResolvingSymlinks(repository.workingDirectory, .scratchDirectory)
    try assertEqualResolvingSymlinks(
      repository.gitDirectory,
      URL.scratchDirectory.appending(path: ".git")
    )
  }
}
