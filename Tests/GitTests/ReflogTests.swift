import Foundation
import Git
import Testing

@Suite("Reflog")
struct ReflogTests {

  @Test func name() throws {
    let name = Reflog.Name("Custom")
    #expect(name.description == "Custom")
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func reflog() throws {
    let cloneDate = Date()
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let reflog = try repository.reflog
    #expect(reflog.items.count == 1)
    let item = try #require(reflog.items.last)
    //            #expect(item.message == "checkout: moving from master to main")
    #expect(
      item.old.description == "0000000000000000000000000000000000000000"
    )
    #expect(
      item.new.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(item.committer.name == "Daniel Tull")
    #expect(item.committer.email == "dt@danieltull.co.uk")
    // The date for a reflog item is when it occurred, in this case when
    // the repo was cloned at the start of this test.
    let timeInterval = item.committer.date.timeIntervalSince(cloneDate)
    #expect(timeInterval < 1)
    #expect(timeInterval > -1)
    #expect(
      item.committer.timeZone
        == TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    )

  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func append() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let reflog = try repository.reflog(named: "CUSTOM")
    #expect(reflog.items.count == 0)

    try reflog.append(.testItem(id: repository.head.target))
    #expect(reflog.items.count == 1)

    let item = try #require(reflog.items.first)
    #expect(item.message == "Test Message")
    #expect(
      item.old.description == "0000000000000000000000000000000000000000"
    )
    #expect(
      item.new.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(item.committer.name == "Test Name")
    #expect(item.committer.email == "Test Email")
    #expect(item.committer.date == Date(timeIntervalSince1970: 1999))
    #expect(item.committer.timeZone == TimeZone(secondsFromGMT: 120))
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func remove() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let reflog = try repository.reflog(named: "CUSTOM")
    #expect(reflog.items.count == 0)

    try reflog.append(.testItem(id: repository.head.target))
    #expect(reflog.items.count == 1)

    try reflog.remove(#require(reflog.items.first))
    #expect(reflog.items.count == 0)
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func write() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    do {
      let reflog = try repository.reflog(named: "CUSTOM")
      #expect(reflog.items.count == 0)
      try reflog.append(.testItem(id: repository.head.target))
      try reflog.write()
    }

    do {
      let reflog = try repository.reflog(named: "CUSTOM")
      #expect(reflog.items.count == 1)

      let item = try #require(reflog.items.first)
      #expect(item.message == "Test Message")
      #expect(
        item.old.description == "0000000000000000000000000000000000000000"
      )
      #expect(
        item.new.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(item.committer.name == "Test Name")
      #expect(item.committer.email == "Test Email")
      #expect(item.committer.date == Date(timeIntervalSince1970: 1999))
      #expect(item.committer.timeZone == TimeZone(secondsFromGMT: 120))
    }
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func rename() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    do {
      let reflog = try repository.reflog(named: "OLD")
      #expect(reflog.items.count == 0)
      try reflog.append(.testItem(id: repository.head.target))
      try reflog.write()
      #expect(reflog.items.count == 1)
    }

    try repository.renameReflog(from: "OLD", to: "NEW")

    do {
      let reflog = try repository.reflog(named: "NEW")
      #expect(reflog.items.count == 1)

      let item = try #require(reflog.items.first)
      #expect(item.message == "Test Message")
      #expect(
        item.old.description == "0000000000000000000000000000000000000000"
      )
      #expect(
        item.new.description == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
      )
      #expect(item.committer.name == "Test Name")
      #expect(item.committer.email == "Test Email")
      #expect(item.committer.date == Date(timeIntervalSince1970: 1999))
      #expect(item.committer.timeZone == TimeZone(secondsFromGMT: 120))
    }
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func delete() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    #expect(try repository.reflog(named: "REFLOG_TEST").items.count == 0)

    let reflog = try repository.reflog(named: "REFLOG_TEST")
    try reflog.append(.testItem(id: repository.head.target))
    try reflog.write()

    #expect(try repository.reflog(named: "REFLOG_TEST").items.count == 1)

    try repository.deleteReflog(named: "REFLOG_TEST")
    #expect(try repository.reflog(named: "REFLOG_TEST").items.count == 0)
  }
}

extension Reflog.Item.Draft {

  fileprivate static func testItem(id: Object.ID) throws -> Self {
    try Reflog.Item.Draft(
      id: id,
      message: "Test Message",
      committer: Signature(
        name: "Test Name",
        email: "Test Email",
        date: Date(timeIntervalSince1970: 1999),
        timeZone: #require(TimeZone(secondsFromGMT: 120))
      )
    )
  }
}
