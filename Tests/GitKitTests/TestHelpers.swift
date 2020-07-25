
import Foundation
import XCTest

extension FileManager {

    func withTemporaryDirectory(_ perform: (URL) throws -> ()) throws {
        let url = temporaryDirectory
            .appendingPathComponent("GitKitTests")
            .appendingPathComponent(UUID().uuidString)
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
        try perform(url)
        try removeItem(at: url)
    }
}

extension Bundle {

    func url(forRepository repository: String) throws -> URL {
        try XCTUnwrap(url(forResource: "Repositories", withExtension: nil))
            .appendingPathComponent(repository)
    }
}

struct IndexOutOfBounds<C: Collection>: Error, CustomStringConvertible {
    let collection: C
    let index: C.Index
    var description: String {
        "Attempted to access index \(index) in \(collection)"
    }
}

extension Collection {

    func value(at index: Index) throws -> Element {
        guard startIndex <= index else { throw IndexOutOfBounds(collection: self, index: index) }
        guard index < endIndex else { throw IndexOutOfBounds(collection: self, index: index) }
        return self[index]
    }
}
