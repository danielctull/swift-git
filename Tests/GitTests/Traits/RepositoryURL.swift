import Foundation
import Testing

extension URL {
  @TaskLocal static var repository = URL
    .temporaryDirectory
    .appending(path: UUID().uuidString)
}

extension Trait where Self == RepositoryURL {
  static func repositoryURL(_ name: RepositoryURL.Name) -> Self {
    RepositoryURL(name: name)
  }
}

struct RepositoryURL: TestTrait, TestScoping {

  fileprivate let name: Name

  func provideScope(
    for test: Test,
    testCase: Test.Case?,
    performing function: () async throws -> Void
  ) async throws {

    let url = Bundle.module
      .url(forResource: "Repositories", withExtension: nil)?
      .appending(path: name.value, directoryHint: .isDirectory)

    try await URL.$repository.withValue(#require(url)) {
      try await function()
    }
  }
}

// MARK: - RepositoryURL.Name

extension RepositoryURL {
  struct Name {
    fileprivate let value: String
  }
}

extension RepositoryURL.Name: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self.init(value: value)
  }
}
