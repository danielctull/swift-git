import Foundation
import Git
import Testing

@Suite("Tag")
struct TagTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryTags() throws {
    let repo = try Repository.clone(.repository, to: .scratchDirectory)
    let tags = try repo.tags
    #expect(tags.count == 2)

    let tag0 = try #require(tags.first)
    #expect(tag0.id.description == "refs/tags/1.0")
    #expect(tag0.reference.description == "refs/tags/1.0")
    #expect(tag0.name == "1.0")
    #expect(
      tag0.target.description == "17e26bc76cff375603e7173dac31e5183350e559"
    )
    //            guard case let .annotated(annotatedID, annotatedTag) = tag0 else { Issue.record("Expected annotated tag"); return }
    //            #expect(annotatedID == "refs/tags/1.0")
    //            #expect(annotatedTag.id.description == "b1c37c042a0c7d5ba7252719850c15355ebdf7c6")
    //            #expect(annotatedTag.name.description == "1.0")
    //            #expect(annotatedTag.target.description == "17e26bc76cff375603e7173dac31e5183350e559")
    //            #expect(annotatedTag.message == "First version.\n\nThis is the first tagged version.\n")
    //            #expect(annotatedTag.tagger.date == Date(timeIntervalSince1970: 1595183180))
    //            #expect(annotatedTag.tagger.email == "dt@danieltull.co.uk")
    //            #expect(annotatedTag.tagger.name == "Daniel Tull")
    //            #expect(annotatedTag.tagger.timeZone == TimeZone(secondsFromGMT: 3600))

    let tag1 = try #require(tags.last)
    #expect(tag1.id.description == "refs/tags/lightweight-tag")
    #expect(tag1.reference.description == "refs/tags/lightweight-tag")
    #expect(tag1.name == "lightweight-tag")
    #expect(
      tag1.target.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    //            guard case let .lightweight(lightweightID, lightweightTarget) = tag1 else { Issue.record("Expected lightweight tag"); return }
    //            #expect(lightweightID == "refs/tags/lightweight-tag")
    //            #expect(lightweightTarget.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func delete() throws {
    let repo = try Repository.clone(.repository, to: .scratchDirectory)
    let tags = try repo.tags
    #expect(tags.count == 2)
    let tag0 = try #require(tags.first)
    try repo.delete(.tag(tag0))
    #expect(try repo.tags.count == 1)
    #expect(throws: (any Error).self) { try repo.tag(named: tag0.name) }
  }
}
