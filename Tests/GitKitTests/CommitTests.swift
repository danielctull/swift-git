
import Foundation
import XCTest
import GitKit

final class CommitTests: XCTestCase {

    func testRepositoryCommits() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branches = try repo.branches()
            let main = try XCTUnwrap(branches.first(where: { $0.name == "main" }))
            let commits = try repo.commits(in: main)
            XCTAssertEqual(commits.count, 1)
            let last = try XCTUnwrap(commits.last)
            XCTAssertEqual(last.message, "Add readme\n")
            XCTAssertEqual(last.id.description, "17e26bc76cff375603e7173dac31e5183350e559")
            XCTAssertEqual(last.author.name, "Daniel Tull")
            XCTAssertEqual(last.author.email, "dt@danieltull.co.uk")
            XCTAssertEqual(last.author.date, Date(timeIntervalSince1970: 1595183161))
            XCTAssertEqual(last.author.timeZone, TimeZone(secondsFromGMT: 3600))
            let first = try XCTUnwrap(commits.first)
            XCTAssertEqual(main.objectID, first.id.rawValue)
        }
    }
}
