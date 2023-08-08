
import Foundation
import Git
import XCTest

@GitActor
final class ReflogTests: XCTestCase {

    func testRepositoryReflog() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let cloneDate = Date()
            let repo = try Repository(local: local, remote: remote)
            let reflog = try repo.reflog
            XCTAssertEqual(try reflog.items.count, 1)
            let item = try XCTUnwrap(reflog.items.last)
//            XCTAssertEqual(item.message, "checkout: moving from master to main")
            XCTAssertEqual(item.old.description, "0000000000000000000000000000000000000000")
            XCTAssertEqual(item.new.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(item.committer.name, "Daniel Tull")
            XCTAssertEqual(item.committer.email, "dt@danieltull.co.uk")
            // The date for a reflog item is when it occurred, in this case when
            // the repo was cloned at the start of this test.
            XCTAssertEqual(item.committer.date.timeIntervalSince1970, cloneDate.timeIntervalSince1970, accuracy: 1)
            XCTAssertEqual(item.committer.timeZone, TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT()))
        }
    }

    func testAddItem() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in

            let repo = try Repository(local: local, remote: remote)
            let reflog = try repo.reflog

            try reflog.addItem(
                id: repo.head.target,
                message: "Test Message",
                committer: Signature(
                    name: "Test Name",
                    email: "Test Email",
                    date: Date(timeIntervalSince1970: 1999),
                    timeZone: XCTUnwrap(TimeZone(secondsFromGMT: 120))))

            let item = try XCTUnwrap(reflog.items.first)
            XCTAssertEqual(item.message, "Test Message")
            XCTAssertEqual(item.old.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(item.new.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
            XCTAssertEqual(item.committer.name, "Test Name")
            XCTAssertEqual(item.committer.email, "Test Email")
            XCTAssertEqual(item.committer.date, Date(timeIntervalSince1970: 1999))
            XCTAssertEqual(item.committer.timeZone, TimeZone(secondsFromGMT: 120))
        }
    }

    func testWrite() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in

            let repo = try Repository(local: local, remote: remote)
            let reflog = try repo.reflog

            try reflog.addItem(
                id: repo.head.target,
                message: "Test Message",
                committer: Signature(
                    name: "Test Name",
                    email: "Test Email",
                    date: Date(timeIntervalSince1970: 1999),
                    timeZone: XCTUnwrap(TimeZone(secondsFromGMT: 120))))

            do {
                let item = try XCTUnwrap(repo.reflog.items.first)
                XCTAssertEqual(item.old.description, "0000000000000000000000000000000000000000")
                XCTAssertEqual(item.committer.name, "Daniel Tull")
            }

            try reflog.write()

            do {
                let item = try XCTUnwrap(repo.reflog.items.first)
                XCTAssertEqual(item.message, "Test Message")
                XCTAssertEqual(item.old.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
                XCTAssertEqual(item.new.description, "b1d2dbab22a62771db0c040ccf396dbbfdcef052")
                XCTAssertEqual(item.committer.name, "Test Name")
                XCTAssertEqual(item.committer.email, "Test Email")
                XCTAssertEqual(item.committer.date, Date(timeIntervalSince1970: 1999))
                XCTAssertEqual(item.committer.timeZone, TimeZone(secondsFromGMT: 120))
            }
        }
    }
}
