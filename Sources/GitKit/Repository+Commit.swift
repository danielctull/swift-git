
import Clibgit2

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

extension Repository {

    public func commit(for id: Commit.ID) throws -> Commit {
        var oid = id.rawValue.oid
        let commit = try GitPointer(
            create: repository.create(git_commit_lookup, &oid),
            free: git_commit_free)
        return try Commit(commit)
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
        for references: [Reference] = [],
        sortedBy sortOptions: SortOptions = SortOptions(),
        includeHead: Bool = true
    ) throws -> [Commit] {

        try GitIterator(
            createIterator: repository.create(git_revwalk_new),
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
                return git_commit_lookup(commit, repository.pointer, oid)
            },
            freeElement: git_commit_free)
            .map(Commit.init)
    }
}
