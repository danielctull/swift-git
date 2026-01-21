import Foundation
import Testing

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
