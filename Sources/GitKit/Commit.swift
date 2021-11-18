
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

    public var tree: Tree {
        get throws {
            let pointer = try GitPointer(
                create: commit.create(git_commit_tree),
                free: git_tree_free)
            return try Tree(pointer)
        }
    }

    public var parentIDs: [ID] {
        (0..<commit.get(git_commit_parentcount)).map { index in
            ID(git_commit_parent_id(commit.pointer, index).pointee)
        }
    }

    public var parents: [Commit] {
        get throws {
            try (0..<commit.get(git_commit_parentcount)).map { index in
                try GitPointer(create: commit.create(git_commit_parent, index),
                               free: git_commit_free)
            }
            .map(Commit.init)
        }
    }
}

// MARK: - Commit.ID

extension Commit.ID {

    init(_ oid: git_oid) {
        self.init(rawValue: Object.ID(oid))
    }
}

extension Commit.ID {

    public var shortDescription: String { String(description.dropLast(33)) }
}

// MARK: - CustomDebugStringConvertible

extension Commit: CustomDebugStringConvertible {

    public var debugDescription: String {
        "Commit(id: \(id.shortDescription), summary: \(summary))"
    }
}
