
import Foundation
import Git
import XCTest

@GitActor
final class SignatureTests: XCTestCase {

    func testDefaultSignature() throws {
        let remote = try Bundle.module.url(forRepository: "Test.git")
        try FileManager.default.withTemporaryDirectory { local in
            let repo = try Repository(local: local, remote: remote)

            let date = Date()
            let signature = try repo.defaultSignature

            // TODO: Currently these are system-based.
            // XCTAssertEqual(signature.name, "")
            // XCTAssertEqual(signature.email, "")
            XCTAssertEqual(signature.date.timeIntervalSince1970, date.timeIntervalSince1970, accuracy: 1)
            XCTAssertEqual(signature.timeZone, TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT()))
        }
    }
}
