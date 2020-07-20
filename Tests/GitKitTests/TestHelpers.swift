
import Foundation
import XCTest

extension FileManager {

    func withTemporaryDirectory(_ perform: (URL) throws -> ()) throws {
        let url = temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
        try perform(url)
        try removeItem(at: url)
    }
}

extension Bundle {

    func url(forRepository repository: String) throws -> URL {
        let repositories = try XCTUnwrap(url(forResource: "Repositories", withExtension: nil))
        return repositories.appendingPathComponent(repository)
    }
}
