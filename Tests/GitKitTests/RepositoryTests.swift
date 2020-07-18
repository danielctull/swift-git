
import Foundation
import XCTest
import GitKit

final class RepositoryTests: XCTestCase {

    func testCreate() throws {
        try FileManager.default.withTemporaryDirectory { url in
            XCTAssertNoThrow(try Repository(url: url))
        }
    }
}

extension FileManager {

    func withTemporaryDirectory(_ perform: (URL) throws -> ()) throws {
        let url = temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
        try perform(url)
        try removeItem(at: url)
    }
}
