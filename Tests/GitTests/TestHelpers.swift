import Foundation
import XCTest

extension FileManager {

  func withTemporaryDirectory(_ perform: (URL) throws -> Void) throws {
    let url = temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try createDirectory(at: url, withIntermediateDirectories: true)
    defer { try? removeItem(at: url) }
    try perform(url)
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
    guard startIndex <= index else { throw IndexOutOfBounds(collection: self, index: index) }
    guard index < endIndex else { throw IndexOutOfBounds(collection: self, index: index) }
    return self[index]
  }
}
