import Foundation
import Git
import Testing

@Suite("Reference")
struct ReferenceTests {

  @Test(.scratchDirectory(.random))
  func throwsUnbornBranchError() throws {

    let repository = try Repository.create(.scratchDirectory)
    let error = try #require(
      #expect(throws: GitError.self) { try repository.head }
    )
    #expect(error.code == .unbornBranch)
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func head() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let head = try repository.head
    guard case .branch(let branch) = head else {
      Issue.record("Expected branch")
      return
    }
    #expect(branch.name == "main")
    #expect(branch.reference.description == "refs/heads/main")
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func repositoryReferences() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)
    let references = try Array(repository.references)
    #expect(references.count == 5)
    #expect(try references.value(at: 0).id == "refs/heads/main")
    #expect(
      try references.value(at: 0).target.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(
      try references.value(at: 0).debugDescription
        == "Branch(name: main, reference: refs/heads/main, target: b1d2dba)"
    )
    #expect(try references.value(at: 1).id == "refs/remotes/origin/HEAD")
    #expect(
      try references.value(at: 1).target.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(
      try references.value(at: 1).debugDescription
        == "RemoteBranch(name: origin/HEAD, reference: refs/remotes/origin/HEAD, target: b1d2dba)"
    )
    #expect(try references.value(at: 2).id == "refs/remotes/origin/main")
    #expect(
      try references.value(at: 2).target.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(
      try references.value(at: 2).debugDescription
        == "RemoteBranch(name: origin/main, reference: refs/remotes/origin/main, target: b1d2dba)"
    )
    #expect(try references.value(at: 3).id == "refs/tags/1.0")
    #expect(
      try references.value(at: 3).target.description
        == "17e26bc76cff375603e7173dac31e5183350e559"
    )
    #expect(
      try references.value(at: 3).debugDescription
        == "Tag(name: 1.0, reference: refs/tags/1.0, target: 17e26bc)"
    )
    #expect(try references.value(at: 4).id == "refs/tags/lightweight-tag")
    #expect(
      try references.value(at: 4).target.description
        == "b1d2dbab22a62771db0c040ccf396dbbfdcef052"
    )
    #expect(
      try references.value(at: 4).debugDescription
        == "Tag(name: lightweight-tag, reference: refs/tags/lightweight-tag, target: b1d2dba)"
    )
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func delete() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    do {
      let references = try Array(repository.references)
      #expect(references.count == 5)
      #expect(try references.value(at: 0).id == "refs/heads/main")
      #expect(try references.value(at: 1).id == "refs/remotes/origin/HEAD")
      #expect(try references.value(at: 2).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 3).id == "refs/tags/1.0")
      #expect(try references.value(at: 4).id == "refs/tags/lightweight-tag")
      try repository.delete(references.value(at: 0))
    }

    do {
      let references = try Array(repository.references)
      #expect(references.count == 4)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/HEAD")
      #expect(try references.value(at: 1).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 2).id == "refs/tags/1.0")
      #expect(try references.value(at: 3).id == "refs/tags/lightweight-tag")
      try repository.delete(references.value(at: 0))
    }

    do {
      let references = try Array(repository.references)
      #expect(references.count == 3)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 1).id == "refs/tags/1.0")
      #expect(try references.value(at: 2).id == "refs/tags/lightweight-tag")
      try repository.delete(references.value(at: 1))
    }

    do {
      let references = try Array(repository.references)
      #expect(references.count == 2)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 1).id == "refs/tags/lightweight-tag")
      try repository.delete(references.value(at: 1))
    }

    do {
      let references = try Array(repository.references)
      #expect(references.count == 1)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
    }
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func removeReferenceByID() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    do {
      let references = try Array(repository.references)
      #expect(references.count == 5)
      #expect(try references.value(at: 0).id == "refs/heads/main")
      #expect(try references.value(at: 1).id == "refs/remotes/origin/HEAD")
      #expect(try references.value(at: 2).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 3).id == "refs/tags/1.0")
      #expect(try references.value(at: 4).id == "refs/tags/lightweight-tag")
    }

    #expect(throws: (any Error).self) {
      try repository.remove("refs/heads/not-here")
    }

    do {
      try repository.remove("refs/heads/main")
      let references = try Array(repository.references)
      #expect(references.count == 4)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/HEAD")
      #expect(try references.value(at: 1).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 2).id == "refs/tags/1.0")
      #expect(try references.value(at: 3).id == "refs/tags/lightweight-tag")
    }

    do {
      try repository.remove("refs/remotes/origin/HEAD")
      let references = try Array(repository.references)
      #expect(references.count == 3)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 1).id == "refs/tags/1.0")
      #expect(try references.value(at: 2).id == "refs/tags/lightweight-tag")
    }

    do {
      try repository.remove("refs/tags/1.0")
      let references = try Array(repository.references)
      #expect(references.count == 2)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 1).id == "refs/tags/lightweight-tag")
    }

    do {
      try repository.remove("refs/tags/lightweight-tag")
      let references = try Array(repository.references)
      #expect(references.count == 1)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
    }
  }

  @Test(.scratchDirectory(.random), .repositoryURL("Test.git"))
  func removeReference() throws {
    let repository = try Repository.clone(.repository, to: .scratchDirectory)

    do {
      let references = try Array(repository.references)
      #expect(references.count == 5)
      #expect(try references.value(at: 0).id == "refs/heads/main")
      #expect(try references.value(at: 1).id == "refs/remotes/origin/HEAD")
      #expect(try references.value(at: 2).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 3).id == "refs/tags/1.0")
      #expect(try references.value(at: 4).id == "refs/tags/lightweight-tag")
    }

    do {
      try repository.remove(try repository.reference(for: "refs/heads/main"))
      let references = try Array(repository.references)
      #expect(references.count == 4)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/HEAD")
      #expect(try references.value(at: 1).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 2).id == "refs/tags/1.0")
      #expect(try references.value(at: 3).id == "refs/tags/lightweight-tag")
    }

    do {
      try repository.remove(
        try repository.reference(for: "refs/remotes/origin/HEAD")
      )
      let references = try Array(repository.references)
      #expect(references.count == 3)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 1).id == "refs/tags/1.0")
      #expect(try references.value(at: 2).id == "refs/tags/lightweight-tag")
    }

    do {
      try repository.remove(try repository.reference(for: "refs/tags/1.0"))
      let references = try Array(repository.references)
      #expect(references.count == 2)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
      #expect(try references.value(at: 1).id == "refs/tags/lightweight-tag")
    }

    do {
      try repository.remove(
        try repository.reference(for: "refs/tags/lightweight-tag")
      )
      let references = try Array(repository.references)
      #expect(references.count == 1)
      #expect(try references.value(at: 0).id == "refs/remotes/origin/main")
    }
  }
}
