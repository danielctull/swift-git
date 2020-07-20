
import Foundation
import XCTest
import GitKit

final class RepositoryTests: XCTestCase {

    func testClone() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            XCTAssertNoThrow(try Repository(local: local, remote: remote))
        }
    }

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

    func testOpen() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            XCTAssertNoThrow(try Repository(local: local, remote: remote))
            XCTAssertNoThrow(try Repository(url: local, options: .open))
        }
    }

    func testRemoteBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranches = try repo.remoteBranches()
            XCTAssertEqual(remoteBranches.count, 1)
            XCTAssertEqual(remoteBranches.first?.name, "origin/main")
            XCTAssertEqual(remoteBranches.first?.id, RemoteBranch.ID(rawValue: "refs/remotes/origin/main"))
        }
    }

    func testTags() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let tags = try repo.tags()
            XCTAssertEqual(tags.count, 1)
            XCTAssertEqual(tags.first?.id, Tag.ID(rawValue: "refs/tags/1.0"))
        }
    }
}

extension Bundle {

    func url(forRepository repository: String) throws -> URL {
        let repositories = try XCTUnwrap(url(forResource: "Repositories", withExtension: nil))
        return repositories.appendingPathComponent(repository)
    }
}
