import Foundation
import Git
import Testing

@Suite("Commit")
struct CommitTests {

  @Test func repositoryCommitForString() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let commit = try repo.commit(
        for: "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      #expect(commit.summary == "Add a file")
      #expect(commit.body == nil)
      #expect(
        commit.id.description == "41c143541c9d917db83ce4e920084edbf2a4177e"
      )
      #expect(commit.author.name == "Daniel Tull")
      #expect(commit.author.email == "dt@danieltull.co.uk")
      #expect(commit.author.date == Date(timeIntervalSince1970: 1_595_676_911))
      #expect(commit.author.timeZone == TimeZone(secondsFromGMT: 3600))
      #expect(commit.committer.name == "Daniel Tull")
      #expect(commit.committer.email == "dt@danieltull.co.uk")
      #expect(
        commit.committer.date == Date(timeIntervalSince1970: 1_595_676_911)
      )
      #expect(commit.committer.timeZone == TimeZone(secondsFromGMT: 3600))
      #expect(
        commit.debugDescription == "Commit(id: 41c1435, summary: Add a file)"
      )
    }
  }

  @Test func repositoryCommits() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let branches = try Array(repo.branches)
      let main = try #require(branches.first(where: { $0.name == "main" }))
      let commits = try Array(repo.commits)
      #expect(commits.count == 4)
      let last = try #require(commits.last)
      #expect(last.summary == "Add readme")
      #expect(last.body == nil)
      #expect(last.id.description == "17e26bc76cff375603e7173dac31e5183350e559")
      #expect(last.author.name == "Daniel Tull")
      #expect(last.author.email == "dt@danieltull.co.uk")
      #expect(last.author.date == Date(timeIntervalSince1970: 1_595_183_161))
      #expect(last.author.timeZone == TimeZone(secondsFromGMT: 3600))
      #expect(last.committer.name == "Daniel Tull")
      #expect(last.committer.email == "dt@danieltull.co.uk")
      #expect(last.committer.date == Date(timeIntervalSince1970: 1_595_183_161))
      #expect(last.committer.timeZone == TimeZone(secondsFromGMT: 3600))
      #expect(
        last.debugDescription == "Commit(id: 17e26bc, summary: Add readme)"
      )
      #expect(try last.parents.count == 0)
      #expect(last.parentIDs.count == 0)
      let first = try #require(commits.first)
      #expect(main.target == first.id.objectID)
      let parentIDs = Array(first.parentIDs)
      #expect(parentIDs.count == 2)
      #expect(
        try parentIDs.value(at: 0).description
          == "17e26bc76cff375603e7173dac31e5183350e559"
      )
      #expect(
        try parentIDs.value(at: 1).description
          == "c8b08c2ed176eaaf7cea877f774319a27684870a"
      )
    }
  }

  @Test func repositoryCommitsZeroSearch() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let commits = try Array(repo.commits(for: [], includeHead: false))
      #expect(commits.count == 0)
    }
  }

  @Test func commitTree() throws {
    let remote = try Bundle.module.url(forRepository: "Test.git")
    try FileManager.default.withTemporaryDirectory { local in
      let repo = try Repository(local: local, remote: remote)
      let commits = try Array(repo.commits)
      let last = try #require(commits.last)
      let tree = try last.tree
      #expect(tree.id.description == "017acad83ffb24d951581417f150bf31673e45b6")
      #expect(tree.entries.count == 1)
      let entry = try Array(tree.entries).value(at: 0)
      #expect(entry.name == "README.md")
      let object = try repo.object(for: entry.target)
      #expect(
        object.id.description == "e5c0a8638a0d8dfa0c733f9d666c511f7e1f9a96"
      )
      guard case .blob(let blob) = object else {
        Issue.record("Expected blob")
        return
      }
      #expect(blob.id.description == "e5c0a8638a0d8dfa0c733f9d666c511f7e1f9a96")
      #expect(!blob.isBinary)
      #expect(
        String(data: blob.data, encoding: .utf8) == "This is a test repository."
      )
    }
  }
}
