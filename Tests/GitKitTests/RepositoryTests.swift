
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

    func testBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branches = try repo.branches()
            XCTAssertEqual(branches.count, 1)
            XCTAssertEqual(branches.first?.name, "main")
            XCTAssertEqual(branches.first?.fullName, "refs/heads/main")
            XCTAssertEqual(branches.first?.objectID.description, "17e26bc76cff375603e7173dac31e5183350e559")
        }
    }

    func testRemoteBranches() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let remoteBranches = try repo.remoteBranches()
            XCTAssertEqual(remoteBranches.count, 1)
            XCTAssertEqual(remoteBranches.first?.name, "origin/main")
            XCTAssertEqual(remoteBranches.first?.fullName, "refs/remotes/origin/main")
        }
    }

    func testTags() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let tags = try repo.tags()
            XCTAssertEqual(tags.count, 1)
            XCTAssertEqual(tags.first?.fullName, "refs/tags/1.0")
        }
    }
}

extension Bundle {

    func url(forRepository repository: String) throws -> URL {
        let repositories = try XCTUnwrap(url(forResource: "Repositories", withExtension: nil))
        return repositories.appendingPathComponent(repository)
    }
}
