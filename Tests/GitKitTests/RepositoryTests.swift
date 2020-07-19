
import Foundation
import XCTest
import GitKit

final class RepositoryTests: XCTestCase {

    func testCreate() throws {
        try FileManager.default.withTemporaryDirectory { url in
            XCTAssertNoThrow(try Repository(url: url))
        }
    }

    func testCreateBare() throws {
        try FileManager.default.withTemporaryDirectory { url in
            XCTAssertNoThrow(try Repository(url: url, options: .create(isBare: true)))
        }
    }

    func testCreateNotBare() throws {
        try FileManager.default.withTemporaryDirectory { url in
            XCTAssertNoThrow(try Repository(url: url, options: .create(isBare: false)))
        }
    }

    func testClone() throws {
        let remote = try Bundle.module.url(forRepository: "GitKit.git")
        try FileManager.default.withTemporaryDirectory { local in
            XCTAssertNoThrow(try Repository(local: local, remote: remote))
        }
    }
}


extension Bundle {

    func url(forRepository repository: String) throws -> URL {
        let repositories = try XCTUnwrap(url(forResource: "Repositories", withExtension: nil))
        return repositories.appendingPathComponent(repository)
    }
}
