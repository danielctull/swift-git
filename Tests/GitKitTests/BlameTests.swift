
import Foundation
import GitKit
import XCTest

final class BlameTests: XCTestCase {

    func testBlame() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let blame = try repo.blame(for: "file.txt")
            let hunks = try blame.hunks()
            XCTAssertEqual(hunks.count, 1)
            let hunk = try hunks.value(at: 0)
            XCTAssertEqual(hunk.commitID.description, "41c143541c9d917db83ce4e920084edbf2a4177e")
            XCTAssertEqual(hunk.lines.lowerBound, 1)
            XCTAssertEqual(hunk.lines.upperBound, 1)
            XCTAssertEqual(hunk.signature.date, Date(timeIntervalSince1970: 1595676911))
            XCTAssertEqual(hunk.signature.email, "dt@danieltull.co.uk")
            XCTAssertEqual(hunk.signature.name, "Daniel Tull")
            XCTAssertEqual(hunk.path, "file.text")
            XCTAssertEqual(try blame.hunk(for: 1), hunk)
        }
    }
}
