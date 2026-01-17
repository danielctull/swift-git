import Foundation
import Git
import Testing

@Suite("Checkout")
struct CheckoutTests {

  @Test(.scratchDirectory)
  func checkoutHead() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    let repo = try Repository.clone(remote, to: .scratchDirectory)
    let file = URL.scratchDirectory.appending(path: UUID().uuidString)
    let content = UUID().uuidString
    try Data(content.utf8).write(to: file)
    #expect(try String(contentsOf: file) == content)
    try repo.checkoutHead()
    //            #expect(throws: (any Error).self) { try String(contentsOf: file })
  }

}
