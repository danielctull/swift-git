import Foundation
import Git
import Testing

@Suite("Worktree")
struct WorktreeTests {

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func empty() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    try #expect(repository.worktrees.isEmpty)
  }
}
