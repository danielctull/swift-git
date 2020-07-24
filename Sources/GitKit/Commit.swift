
import Clibgit2
import Tagged

public struct Commit: Identifiable {
    let commit: GitPointer
    public typealias ID = Tagged<Commit, ObjectID>
    public let id: ID
    public let summary: String
    public let body: String?
    public let author: Signature
    public let committer: Signature

    init(_ pointer: GitPointer) throws {
        commit = pointer
        id = try ID(rawValue: ObjectID(commit.get(git_commit_id)))
        summary = try String(commit.get(git_commit_summary))
        body = try? String(commit.get(git_commit_body))
        author = try Signature(commit.get(git_commit_author))
        committer = try Signature(commit.get(git_commit_committer))
    }
}

extension Commit {

    public func parents() throws -> [Commit] {
        let count = commit.get(git_commit_parentcount)
        return try (0..<count).map { index in
            try GitPointer(create: { git_commit_parent($0, commit.pointer, index) },
                           free: git_commit_free)
        }
        .map(Commit.init)
    }
}
