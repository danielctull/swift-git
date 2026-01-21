import Foundation
import Git
import Testing

@Suite("Signature")
struct SignatureTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func defaultSignature() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    let config = try repository.config.level(.local)
    try config.set("Tester Nameson", for: "user.name")
    try config.set("some_address@example.com", for: "user.email")

    let date = Date()
    let signature = try repository.defaultSignature

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
