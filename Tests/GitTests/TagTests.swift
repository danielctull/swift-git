import Foundation
import Git
import XCTest

final class TagTests: XCTestCase {

  func testRepositoryTags() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let tags = try repo.tags
      XCTAssertEqual(tags.count, 2)

      let tag0 = try XCTUnwrap(tags.first)
      XCTAssertEqual(tag0.id.description, "refs/tags/1.0")
      XCTAssertEqual(tag0.reference.description, "refs/tags/1.0")
      XCTAssertEqual(tag0.name, "1.0")
      XCTAssertEqual(
        tag0.target.description,
        "17e26bc76cff375603e7173dac31e5183350e559"
      )
      //            guard case let .annotated(annotatedID, annotatedTag) = tag0 else { XCTFail("Expected annotated tag"); return }
      //            XCTAssertEqual(annotatedID, "refs/tags/1.0")
      //            XCTAssertEqual(annotatedTag.id.description, "b1c37c042a0c7d5ba7252719850c15355ebdf7c6")
      //            XCTAssertEqual(annotatedTag.name.description, "1.0")
      //            XCTAssertEqual(annotatedTag.target.description, "17e26bc76cff375603e7173dac31e5183350e559")
      //            XCTAssertEqual(annotatedTag.message, "First version.\n\nThis is the first tagged version.\n")
      //            XCTAssertEqual(annotatedTag.tagger.date, Date(timeIntervalSince1970: 1595183180))
      //            XCTAssertEqual(annotatedTag.tagger.email, "dt@danieltull.co.uk")
      //            XCTAssertEqual(annotatedTag.tagger.name, "Daniel Tull")
      //            XCTAssertEqual(annotatedTag.tagger.timeZone, TimeZone(secondsFromGMT: 3600))

      let tag1 = try XCTUnwrap(tags.last)
      XCTAssertEqual(tag1.id.description, "refs/tags/lightweight-tag")
      XCTAssertEqual(tag1.reference.description, "refs/tags/lightweight-tag")
      XCTAssertEqual(tag1.name, "lightweight-tag")
      XCTAssertEqual(
        tag1.target.description,
        "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      //            guard case let .lightweight(lightweightID, lightweightTarget) = tag1 else { XCTFail("Expected lightweight tag"); return }
      //            XCTAssertEqual(lightweightID, "refs/tags/lightweight-tag")
      //            XCTAssertEqual(lightweightTarget.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
    }
  }

  func testDelete() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let tags = try repo.tags
      XCTAssertEqual(tags.count, 2)
      let tag0 = try XCTUnwrap(tags.first)
      try repo.delete(.tag(tag0))
      XCTAssertEqual(try repo.tags.count, 1)
      XCTAssertThrowsError(try repo.tag(named: tag0.name))
    }
  }
}
