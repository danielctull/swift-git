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

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func addWorktree() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let path = URL.scratchDirectory.appending(path: "path")

    let worktree = try repository.addWorktree(
      named: "test",
      at: path
    )

    #expect(worktree.name == "test")
    #expect(worktree.path.resolvingSymlinksInPath().path == path.resolvingSymlinksInPath().path)
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func addWorktreeAtReference() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let main = try repository.branch(named: "main")
    let commits = try Array(repository.commits(for: .branch(main)))
    let commit = try #require(commits.first)
    let new = try repository.createBranch(named: "new", at: commit)
    let path = URL.scratchDirectory.appending(path: "path")

    let worktree = try repository.addWorktree(
      named: "test",
      at: path,
      reference: .branch(new)
    )

    #expect(worktree.name == "test")
    #expect(worktree.path.resolvingSymlinksInPath().path == path.resolvingSymlinksInPath().path)
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func worktrees() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let a = URL.scratchDirectory.appending(path: "a")
    let b = URL.scratchDirectory.appending(path: "b")

    _ = try repository.addWorktree(named: "b", at: b)
    _ = try repository.addWorktree(named: "a", at: a)

    try #expect(Array(repository.worktrees) == ["a", "b"])
  }
}
