
import Clibgit2
import Tagged

public struct Commit: Identifiable {
    let commit: GitPointer
    public typealias ID = Tagged<Commit, Object.ID>
    public let id: ID
    public let summary: String
    public let body: String?
    public let author: Signature
    public let committer: Signature

    init(_ pointer: GitPointer) throws {
        commit = pointer
        id = try ID(object: pointer)
        summary = try Unwrap(String(validatingUTF8: commit.get(git_commit_summary)))
        body = try? Unwrap(String(validatingUTF8: commit.get(git_commit_body)))
        author = try Signature(commit.get(git_commit_author))
        committer = try Signature(commit.get(git_commit_committer))
    }
}

extension Commit {

    public func tree() throws -> Tree {
        let pointer = try GitPointer(create: { git_commit_tree($0, commit.pointer) },
                                     free: git_tree_free)
        return try Tree(pointer)
    }

    public var parentIDs: [ID] {
        (0..<commit.get(git_commit_parentcount)).map { index in
            ID(git_commit_parent_id(commit.pointer, index).pointee)
        }
    }

    public func parents() throws -> [Commit] {
        try (0..<commit.get(git_commit_parentcount)).map { index in
            try GitPointer(create: { git_commit_parent($0, commit.pointer, index) },
                           free: git_commit_free)
        }
        .map(Commit.init)
    }
}

// MARK: - Commit.ID

extension Commit.ID {

    init(_ oid: git_oid) {
        self.init(rawValue: Object.ID(oid))
    }
}

// MARK: - CustomDebugStringConvertible

extension Commit: CustomDebugStringConvertible {

    public var debugDescription: String {
        "Commit(id: \(id.rawValue.debugDescription), summary: \(summary))"
    }
}
