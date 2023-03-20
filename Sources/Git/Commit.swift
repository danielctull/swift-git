
import Clibgit2
import Tagged

extension Repository {

    public func commit(for id: Commit.ID) throws -> Commit {
        var oid = id.oid
        return try Commit(
            create: pointer.get(git_commit_lookup, &oid),
            free: git_commit_free)
    }

    public var commits: some Sequence<Commit> {
        get throws {
            try commits(for: [])
        }
    }

    public func commits(
        for references: Reference...,
        sortedBy sortOptions: SortOptions = SortOptions(),
        includeHead: Bool = true
    ) throws -> some Sequence<Commit> {
        try commits(for: references,
                    sortedBy: sortOptions,
                    includeHead: includeHead)
    }

    public func commits(
        for references: [Reference],
        sortedBy sortOptions: SortOptions = SortOptions(),
        includeHead: Bool = true
    ) throws -> some Sequence<Commit> {

        try GitIterator {

            let iterator = try GitPointer(
                create: pointer.get(git_revwalk_new),
                free: git_revwalk_free)

            for reference in references {
                var oid = reference.target.oid
                try iterator.perform(git_revwalk_push, &oid)
            }

            if includeHead {
                try iterator.perform(git_revwalk_push_head)
            }

            try iterator.perform(git_revwalk_sorting, sortOptions.rawValue)

            return iterator

        } nextElement: { iterator in

            var oid: git_oid = try iterator.get(git_revwalk_next)
            return try GitPointer(
                create: pointer.get(git_commit_lookup, &oid),
                free: git_commit_free)
        }
        .map(Commit.init)
    }
}

// MARK: - Commit

public struct Commit: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<Commit, Object.ID>
    public let id: ID
    public let summary: String
    public let body: String?
    public let author: Signature
    public let committer: Signature

    init(pointer: GitPointer) throws {
        self.pointer = pointer
        id = try ID(object: pointer)

        summary = try pointer.get(git_commit_summary) |> String.init
        body = try? pointer.get(git_commit_body) |> String.init
        author = try pointer.get(git_commit_author) |> Signature.init
        committer = try pointer.get(git_commit_committer) |> Signature.init
    }
}

extension Commit {

    public var tree: Tree {
        get throws {
            try Tree(
                create: pointer.get(git_commit_tree),
                free: git_tree_free)
        }
    }

    public var parentIDs: [ID] {
        get throws {
            try GitCollection(
                pointer: pointer,
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
            let count = pointer.get(git_commit_parentcount)
            return try (0..<count).map { index in
                try Commit(
                    create: pointer.get(git_commit_parent, index),
                    free: git_commit_free)
            }
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
        self.init(rawValue: Object.ID(oid: oid))
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
