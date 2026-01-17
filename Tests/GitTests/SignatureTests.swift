import Foundation
import Git
import Testing

@Suite("Signature")
struct SignatureTests {

  @Test func defaultSignature() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)

      let config = try repo.config.level(.local)
      try config.set("Tester Nameson", for: "user.name")
      try config.set("some_address@example.com", for: "user.email")

      let date = Date()
      let signature = try repo.defaultSignature

      #expect(signature.name == "Tester Nameson")
      #expect(signature.email == "some_address@example.com")
      XCTAssertEqual(
        signature.date.timeIntervalSince1970,
        date.timeIntervalSince1970,
        accuracy: 1
      )
      #expect(signature.timeZone == TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT()))
    }
  }
}
