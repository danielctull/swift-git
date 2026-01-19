import Foundation
import Git
import Testing

@Suite("Reflog")
struct ReflogTests {

  @Test func name() throws {
    let name = Reflog.Name("Custom")
    #expect(name.description == "Custom")
  }

  @Test func reflog() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let cloneDate = Date()
      let repo = try Repository(local: local, remote: remote)
      let reflog = try repo.reflog
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
  }

  @Test func append() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in

      let repo = try Repository(local: local, remote: remote)
      let reflog = try repo.reflog(named: "CUSTOM")
      #expect(reflog.items.count == 0)

      try reflog.append(.testItem(id: repo.head.target))
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

  @Test func remove() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in

      let repo = try Repository(local: local, remote: remote)
      let reflog = try repo.reflog(named: "CUSTOM")
      #expect(reflog.items.count == 0)

      try reflog.append(.testItem(id: repo.head.target))
      #expect(reflog.items.count == 1)

      try reflog.remove(#require(reflog.items.first))
      #expect(reflog.items.count == 0)
    }
  }

  @Test func write() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in

      let repo = try Repository(local: local, remote: remote)

      do {
        let reflog = try repo.reflog(named: "CUSTOM")
        #expect(reflog.items.count == 0)
        try reflog.append(.testItem(id: repo.head.target))
        try reflog.write()
      }

      do {
        let reflog = try repo.reflog(named: "CUSTOM")
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
  }

  @Test func rename() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in

      let repo = try Repository(local: local, remote: remote)

      do {
        let reflog = try repo.reflog(named: "OLD")
        #expect(reflog.items.count == 0)
        try reflog.append(.testItem(id: repo.head.target))
        try reflog.write()
        #expect(reflog.items.count == 1)
      }

      try repo.renameReflog(from: "OLD", to: "NEW")

      do {
        let reflog = try repo.reflog(named: "NEW")
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
  }

  @Test func delete() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in

      let repo = try Repository(local: local, remote: remote)

      #expect(try repo.reflog(named: "REFLOG_TEST").items.count == 0)

      let reflog = try repo.reflog(named: "REFLOG_TEST")
      try reflog.append(.testItem(id: repo.head.target))
      try reflog.write()

      #expect(try repo.reflog(named: "REFLOG_TEST").items.count == 1)

      try repo.deleteReflog(named: "REFLOG_TEST")
      #expect(try repo.reflog(named: "REFLOG_TEST").items.count == 0)
    }
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
