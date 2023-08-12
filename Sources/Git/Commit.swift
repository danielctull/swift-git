
import Clibgit2

extension Repository {

    @GitActor
    public func commit(for string: String) throws -> Commit {
        try commit(for: Commit.ID(string))
    }

    @GitActor
    public func commit(for id: Commit.ID) throws -> Commit {
        try withUnsafePointer(to: id.objectID.oid) { oid in
            try Commit(
                create: pointer.create(git_commit_lookup, oid),
                free: git_commit_free)
        }
    }

    @GitActor
    public var commits: GitSequence<Commit> {
        get throws {
            try commits(for: [])
        }
    }

    @GitActor
    public func commits(
        for references: Reference...,
        sortedBy sortOptions: SortOptions = SortOptions(),
        includeHead: Bool = true
    ) throws -> GitSequence<Commit> {
        try commits(for: references,
                    sortedBy: sortOptions,
                    includeHead: includeHead)
    }

    @GitActor
    public func commits(
        for references: [Reference] = [],
        sortedBy sortOptions: SortOptions = SortOptions(),
        includeHead: Bool = true
    ) throws -> GitSequence<Commit> {

        try GitSequence {

            let iterator = try GitPointer(
                create: pointer.create(git_revwalk_new),
                free: git_revwalk_free)

            for reference in references {
                try withUnsafePointer(to: reference.target.oid) { oid in
                    try iterator.perform(git_revwalk_push, oid)
                }
            }

            if includeHead {
                try iterator.perform(git_revwalk_push_head)
            }

            try sortOptions.withRawValue { sortOptions in
                try iterator.perform(git_revwalk_sorting, sortOptions)
            }

            return iterator

        } next: { iterator in

            try withUnsafePointer(to: iterator.get(git_revwalk_next)) { oid in
                try Commit(
                    create: pointer.create(git_commit_lookup, oid),
                    free: git_commit_free)
            }
        }
    }
}

// MARK: - Commit

public struct Commit: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public let id: ID
    public let summary: String
    public let body: String?
    public let author: Signature
    public let committer: Signature

    @GitActor
    init(pointer: GitPointer) {
        self.pointer = pointer
        id = ID(objectID: Object.ID(object: pointer))
        summary = pointer.get(git_commit_summary) !> String.init(cString:)
        body = pointer.get(git_commit_body) ?> String.init(cString:)
        author = pointer.get(git_commit_author) !> Signature.init
        committer = pointer.get(git_commit_committer) !> Signature.init
    }
}

extension Commit {

    @GitActor
    public var tree: Tree {
        get throws {
            try Tree(
                create: pointer.create(git_commit_tree),
                free: git_tree_free)
        }
    }

    @GitActor
    public var parentIDs: GitCollection<Commit.ID> {
        GitCollection {
            pointer.get(git_commit_parentcount)
        } element: { index in
            pointer.get(git_commit_parent_id, index)!.pointee |> ID.init
        }
    }

    @GitActor
    public var parents: [Commit] {
        get throws {
            let count = pointer.get(git_commit_parentcount)
            return try (0..<count).map { index in
                try Commit(
                    create: pointer.create(git_commit_parent, index),
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

extension Commit {

    public struct ID: Equatable, Hashable, Sendable {
        public let objectID: Object.ID
    }
}

extension Commit.ID {

    init(_ oid: git_oid) {
        self.init(objectID: Object.ID(oid: oid))
    }

    @GitActor
    init(_ string: String)throws {
        try self.init(objectID: Object.ID(string))
    }
}

extension Commit.ID: CustomStringConvertible {
    public var description: String { objectID.description }
}

extension Commit.ID {

    public var shortDescription: String { String(objectID.description.dropLast(33)) }
}

// MARK: - SortOptions

public struct SortOptions: OptionSet, Equatable, Hashable, Sendable {
    public let rawValue: Option
    public init(rawValue: Option) {
        self.rawValue = rawValue
    }
}

extension SortOptions: GitOptionSet {

    typealias OptionType = git_sort_t

    /// Sort the output with the same default method from `git`: reverse
    /// chronological order. This is the default sorting for new walkers.
    public static let none = Self(GIT_SORT_NONE)

    /// Sort the repository contents by commit time;
    /// this sorting mode can be combined with
    /// topological sorting.
    public static let time = Self(GIT_SORT_TIME)

    /// Sort the repository contents in topological order (no parents before
    /// all of its children are shown); this sorting mode can be combined
    /// with time sorting to produce `git`'s `--date-order``.
    public static let topological = Self(GIT_SORT_TOPOLOGICAL)

    /// Iterate through the repository contents in reverse
    /// order; this sorting mode can be combined with
    /// any of the above.
    public static let reverse = Self(GIT_SORT_REVERSE)
}

// MARK: - GitPointerInitialization

extension Commit: GitPointerInitialization {}
