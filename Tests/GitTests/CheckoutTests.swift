import Foundation
import Git
import Testing

@Suite("Checkout")
struct CheckoutTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func checkoutHead() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let file = URL.scratchDirectory.appending(path: UUID().uuidString)
    let content = UUID().uuidString
    try Data(content.utf8).write(to: file)
    #expect(try String(contentsOf: file) == content)
    try repository.checkoutHead()
    //            #expect(throws: (any Error).self) { try String(contentsOf: file })
  }

}
