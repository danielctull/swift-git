
import Foundation
import GitKit
import XCTest

final class TagTests: XCTestCase {

    func testRepositoryTags() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let tags = try repo.tags()
            XCTAssertEqual(tags.count, 2)

            let tag0 = try XCTUnwrap(tags.first)
            XCTAssertEqual(tag0.id, "refs/tags/1.0")
            XCTAssertEqual(tag0.name, "1.0")
            XCTAssertEqual(tag0.target.description, "17e26bc76cff375603e7173dac31e5183350e559")
            guard case let .annotated(annotated) = tag0 else { XCTFail(); return }
            XCTAssertEqual(annotated.id, "refs/tags/1.0")
            XCTAssertEqual(annotated.objectID.description, "b1c37c042a0c7d5ba7252719850c15355ebdf7c6")
            XCTAssertEqual(annotated.target.description, "17e26bc76cff375603e7173dac31e5183350e559")
            XCTAssertEqual(annotated.message, "First version.\n\nThis is the first tagged version.\n")
            XCTAssertEqual(annotated.tagger.date, Date(timeIntervalSince1970: 1595183180))
            XCTAssertEqual(annotated.tagger.email, "dt@danieltull.co.uk")
            XCTAssertEqual(annotated.tagger.name, "Daniel Tull")
            XCTAssertEqual(annotated.tagger.timeZone, TimeZone(secondsFromGMT: 3600))

            let tag1 = try XCTUnwrap(tags.last)
            XCTAssertEqual(tag1.id, "refs/tags/lightweight-tag")
            XCTAssertEqual(tag1.name, "lightweight-tag")
            XCTAssertEqual(tag1.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            guard case let .lightweight(lightweight) = tag1 else { XCTFail(); return }
            XCTAssertEqual(lightweight.id, "refs/tags/lightweight-tag")
            XCTAssertEqual(lightweight.target.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
        }
    }
}
