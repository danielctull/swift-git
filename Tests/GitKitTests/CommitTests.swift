
import Foundation
import GitKit
import XCTest

final class CommitTests: XCTestCase {

    func testRepositoryCommits() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let branches = try repo.branches()
            let main = try XCTUnwrap(branches.first(where: { $0.name == "main" }))
            let commits = try repo.commits()
            XCTAssertEqual(commits.count, 4)
            let last = try XCTUnwrap(commits.last)
            XCTAssertEqual(last.summary, "Add readme")
            XCTAssertNil(last.body)
            XCTAssertEqual(last.id.description, "17e26bc76cff375603e7173dac31e5183350e559")
            XCTAssertEqual(last.author.name, "Daniel Tull")
            XCTAssertEqual(last.author.email, "dt@danieltull.co.uk")
            XCTAssertEqual(last.author.date, Date(timeIntervalSince1970: 1595183161))
            XCTAssertEqual(last.author.timeZone, TimeZone(secondsFromGMT: 3600))
            XCTAssertEqual(last.committer.name, "Daniel Tull")
            XCTAssertEqual(last.committer.email, "dt@danieltull.co.uk")
            XCTAssertEqual(last.committer.date, Date(timeIntervalSince1970: 1595183161))
            XCTAssertEqual(last.committer.timeZone, TimeZone(secondsFromGMT: 3600))
            XCTAssertEqual(last.debugDescription, "Commit(id: 17e26bc, summary: Add readme)")
            XCTAssertEqual(try last.parents().count, 0)
            XCTAssertEqual(last.parentIDs.count, 0)
            let first = try XCTUnwrap(commits.first)
            XCTAssertEqual(main.target, first.id.rawValue)
            XCTAssertEqual(first.parentIDs.count, 2)
            XCTAssertEqual(try first.parentIDs.value(at: 0).description, "17e26bc76cff375603e7173dac31e5183350e559")
            XCTAssertEqual(try first.parentIDs.value(at: 1).description, "c8b08c2ed176eaaf7cea877f774319a27684870a")
        }
    }

    func testRepositoryCommitsZeroSearch() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let commits = try repo.commits(for: [], includeHead: false)
            XCTAssertEqual(commits.count, 0)
        }
    }

    func testCommitTree() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let commits = try repo.commits()
            let last = try XCTUnwrap(commits.last)
            let tree = try last.tree
            XCTAssertEqual(tree.id.description, "017acad83ffb24d951581417f150bf31673e45b6")
            XCTAssertEqual(tree.entries.count, 1)
            let entry = try tree.entries.value(at: 0)
            XCTAssertEqual(entry.name, "README.md")
            let object = try repo.object(for: entry.target)
            XCTAssertEqual(object.id.description, "e5c0a8638a0d8dfa0c733f9d666c511f7e1f9a96")
            guard case let .blob(blob) = object else { XCTFail("Expected blob"); return }
            XCTAssertEqual(blob.id.description, "e5c0a8638a0d8dfa0c733f9d666c511f7e1f9a96")
            XCTAssertFalse(blob.isBinary)
            XCTAssertEqual(String(data: blob.data, encoding: .utf8), "This is a test repository.")
        }
    }
}
