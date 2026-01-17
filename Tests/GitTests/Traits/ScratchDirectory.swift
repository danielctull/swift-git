import Foundation
import Testing

extension URL {
  @TaskLocal static var scratchDirectory = URL
    .temporaryDirectory
    .appending(path: UUID().uuidString)
}

extension Trait where Self == ScratchDirectory {
  static var scratchDirectory: Self { Self() }
}

struct ScratchDirectory: TestTrait, TestScoping {

  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: () async throws -> Void
  ) async throws {

    let fileManager = FileManager()
    let url = fileManager
      .temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)

    try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: url) }

    try await URL.$scratchDirectory.withValue(url) {
      try await function()
    }
  }

  public func callAsFunction(_ function: () throws -> Void) throws {

    let fileManager = FileManager()
    let url = fileManager
      .temporaryDirectory
      .appending(path: UUID().uuidString, directoryHint: .isDirectory)

    try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: url) }

    try URL.$scratchDirectory.withValue(url) {
      try function()
    }
  }
}
