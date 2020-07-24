
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
