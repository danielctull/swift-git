import Foundation
import Git
import Testing

@Suite("Checkout")
struct CheckoutTests {

  @Test func checkoutHead() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository.clone(remote, to: local)
      let file = local.appending(path: UUID().uuidString)
      let content = UUID().uuidString
      try Data(content.utf8).write(to: file)
      #expect(try String(contentsOf: file) == content)
      try repo.checkoutHead()
      //            #expect(throws: (any Error).self) { try String(contentsOf: file })
    }
  }
}
