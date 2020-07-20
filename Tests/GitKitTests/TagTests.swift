
import Foundation
import GitKit
import XCTest

final class TagTests: XCTestCase {

    func testRepositoryTags() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let tags = try repo.tags()
            XCTAssertEqual(tags.count, 1)
            let tag = try XCTUnwrap(tags.first)
            XCTAssertEqual(tag.id, Tag.ID(rawValue: "refs/tags/1.0"))
            XCTAssertEqual(tag.objectID.description, "b1c37c042a0c7d5ba7252719850c15355ebdf7c6")
        }
    }
}
