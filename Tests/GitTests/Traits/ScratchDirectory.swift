import Foundation
import Testing

extension URL {
  @TaskLocal static var scratchDirectory = URL
    .temporaryDirectory
    .appending(path: UUID().uuidString)
}

extension Trait where Self == ScratchDirectory {
  static func scratchDirectory(_ name: ScratchDirectory.Name) -> Self {
    ScratchDirectory(name)
  }
}

struct ScratchDirectory: TestTrait, TestScoping {

  fileprivate let name: Name

  init(_ name: Name) {
    self.name = name
  }

  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: () async throws -> Void
  ) async throws {

    let fileManager = FileManager()
    let url = fileManager
      .temporaryDirectory
      .appending(path: name.value, directoryHint: .isDirectory)

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

// MARK: - ScratchDirectory.Name

extension ScratchDirectory {
  struct Name {
    fileprivate let value: String
  }
}

extension ScratchDirectory.Name {
  static var random: ScratchDirectory.Name {
    ScratchDirectory.Name(value: UUID().uuidString)
  }
}

extension ScratchDirectory.Name: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.init(value: value)
  }
}
