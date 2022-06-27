
import Clibgit2
import Tagged

extension Repository {

    public func commit(for id: Commit.ID) throws -> Commit {
        var oid = id.rawValue.oid
        let commit = try GitPointer(
            create: create(git_commit_lookup, &oid),
            free: git_commit_free)
        return try Commit(commit)
    }

    public var commits: [Commit] {
        get throws {
            try commits(for: [])
        }
    }

    public func commits(
        for references: Reference...,
        sortedBy sortOptions: SortOptions = SortOptions(),
        includeHead: Bool = true
    ) throws -> [Commit] {
        try commits(for: references,
                    sortedBy: sortOptions,
                    includeHead: includeHead)
    }

    public func commits(
        for references: [Reference],
        sortedBy sortOptions: SortOptions = SortOptions(),
        includeHead: Bool = true
    ) throws -> [Commit] {

        try GitIterator(
            createIterator: create(git_revwalk_new),
            configureIterator: { iterator in
                for reference in references {
                    var oid = reference.target.oid
                    let result = git_revwalk_push(iterator, &oid)
                    if LibGit2Error(result) != nil { return result }
                }
                if includeHead {
                    let result = git_revwalk_push_head(iterator)
                    if LibGit2Error(result) != nil { return result }
                }
                return git_revwalk_sorting(iterator, sortOptions.rawValue)
            },
            freeIterator: git_revwalk_free,
            nextElement: { commit, iterator in
                let oid = UnsafeMutablePointer<git_oid>.allocate(capacity: 1)
                defer { oid.deallocate() }
                let result = git_revwalk_next(oid, iterator)
                if LibGit2Error(result) != nil { return result }
                return git_commit_lookup(commit, pointer.pointer, oid)
            },
            freeElement: git_commit_free)
            .map(Commit.init)
    }
}

// MARK: - Commit

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
        get throws {
            try GitCollection(
                pointer: commit,
                count: git_commit_parentcount,
                element: git_commit_parent_id
            )
            .map(Unwrap)
            .map(\.pointee)
            .map(ID.init)
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

extension Commit: CustomDebugStringConvertible {

    public var debugDescription: String {
        "Commit(id: \(id.shortDescription), summary: \(summary))"
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

// MARK: - SortOptions

public struct SortOptions: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

extension SortOptions {

    private init(_ sort: git_sort_t) {
        self.init(rawValue: sort.rawValue)
    }

    public init() { self.init(GIT_SORT_NONE) }
    public static let time = Self(GIT_SORT_TIME)
    public static let topological = Self(GIT_SORT_TOPOLOGICAL)
    public static let reverse = Self(GIT_SORT_REVERSE)
}
