import Foundation
import Git
import Testing

@Suite("Signature")
struct SignatureTests {

  @Test(.scratchDirectory(.random))
  func defaultSignature() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    let repo = try Repository.clone(remote, to: .scratchDirectory)

    let config = try repo.config.level(.local)
    try config.set("Tester Nameson", for: "user.name")
    try config.set("some_address@example.com", for: "user.email")

    let date = Date()
    let signature = try repo.defaultSignature

    #expect(signature.name == "Tester Nameson")
    #expect(signature.email == "some_address@example.com")
    let timeInterval = signature.date.timeIntervalSince(date)
    #expect(timeInterval < 1)
    #expect(timeInterval > -1)
    #expect(
      signature.timeZone
        == TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
    )
  }
}
