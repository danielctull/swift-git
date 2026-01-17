import Foundation
import Testing

extension FileManager {

  func withTemporaryDirectory(_ perform: (URL) throws -> Void) throws {
    let url = try Bundle.module.bundleURL
      .parent(where: { $0.lastPathComponent == "Debug" })
      .appendingPathComponent(UUID().uuidString)
    try createDirectory(at: url, withIntermediateDirectories: true)
    try perform(url)
    try removeItem(at: url)
  }
}

extension URL {

  func parent(where predicate: (URL) -> Bool) throws -> URL {
    if predicate(self) { return self }
    struct URLNotFound: Error {}
    guard !pathComponents.isEmpty else { throw URLNotFound() }
    return try deletingLastPathComponent().parent(where: predicate)
  }
}

extension Bundle {

  func url(forRepository repository: String) throws -> URL {
    try XCTUnwrap(url(forResource: "Repositories", withExtension: nil))
      .appendingPathComponent(repository)
  }
}

struct IndexOutOfBounds: Error, CustomStringConvertible {
  let description: String
  init<C: Collection>(collection: C, index: C.Index) {
    description = "Attempted to access index \(index) in \(collection)"
  }
}

extension Collection {

  func value(at index: Index) throws -> Element {
    guard startIndex <= index else {
      throw IndexOutOfBounds(collection: self, index: index)
    }
    guard index < endIndex else {
      throw IndexOutOfBounds(collection: self, index: index)
    }
    return self[index]
  }
}
