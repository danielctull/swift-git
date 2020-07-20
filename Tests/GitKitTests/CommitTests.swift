
import Foundation
import XCTest
import GitKit

final class CommitTests: XCTestCase {

    func testClone() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branches = try repo.branches()
            let main = try XCTUnwrap(branches.first(where: { $0.name == "main" }))
            let commits = try repo.commits(in: main)
            XCTAssertEqual(commits.count, 1)
            let last = try XCTUnwrap(commits.last)
            XCTAssertEqual(last.message, "Add readme\n")
            XCTAssertEqual(last.objectID.description, "17e26bc76cff375603e7173dac31e5183350e559")
        }
    }
}
