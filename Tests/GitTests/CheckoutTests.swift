
import Foundation
import Git
import XCTest

@GitActor
final class CheckoutTests: XCTestCase {

    func testCheckoutHead() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)
            let file = local.appending(path: UUID().uuidString)
            let content = UUID().uuidString
            try Data(content.utf8).write(to: file)
            XCTAssertEqual(try String(contentsOf: file), content)
            try repo.checkoutHead()
//            XCTAssertThrowsError(try String(contentsOf: file))
        }
    }
}
