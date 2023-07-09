
import Foundation
import Git
import XCTest

@GitActor
final class ResetTests: XCTestCase {

    func testResetSoft() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let head = try XCTUnwrap(repo.commits.first(where: { _ in true }))
            let file = local.appending(path: UUID().uuidString)
            let content = UUID().uuidString
            try Data(content.utf8).write(to: file)
            XCTAssertEqual(try String(contentsOf: file), content)
            try repo.reset(to: head, operation: .soft)
            XCTAssertEqual(try String(contentsOf: file), content)
            try repo.reset(to: head, operation: .mixed)
            XCTAssertEqual(try String(contentsOf: file), content)
//            try repo.reset(to: head, operation: .hard)
//            XCTAssertThrowsError(try String(contentsOf: file))
        }
    }
}
