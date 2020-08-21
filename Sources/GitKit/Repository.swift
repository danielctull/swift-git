
import Clibgit2
import Foundation

public struct Repository {
    let repository: GitPointer

    public enum Options {
        case open
        case create(isBare: Bool)

        public static let create = Self.create(isBare: false)
    }

    public init(url: URL, options: Options = .create) throws {
        repository = try GitPointer(create: { pointer in
            url.withUnsafeFileSystemRepresentation { path in
                switch options {
                case .open:               return git_repository_open(pointer, path)
                case .create(let isBare): return git_repository_init(pointer, path, UInt32(isBare))
                }
            }
        }, free: git_repository_free)
    }

    public init(local: URL, remote: URL) throws {

        let remoteString = remote.isFileURL ? remote.path : remote.absoluteString

        repository = try GitPointer(create: { pointer in
            local.withUnsafeFileSystemRepresentation { path in
                git_clone(pointer, remoteString, path, nil)
            }
        }, free: git_repository_free)
    }
}

// MARK: - Git Initialiser

extension Repository {

    init(_ pointer: GitPointer) {
        repository = pointer
    }
}

// MARK: - Head

extension Repository {

    public func head() throws -> Reference {
        let head = try GitPointer(create: { git_repository_head($0, repository.pointer) },
                                  free: git_reference_free)
        return try Reference(head)
    }
}

// MARK: - Branch

extension Repository {

    public func branches() throws -> [Branch] {

        try GitIterator(
            createIterator: { git_branch_iterator_new($0, repository.pointer, GIT_BRANCH_LOCAL) },
            freeIterator: git_branch_iterator_free,
            nextElement: {
                let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
                defer { type.deallocate() }
                return git_branch_next($0, type, $1)
            },
            freeElement: git_reference_free)
            .map(Branch.init)
    }

    public func createBranch(named name: String, at commit: Commit) throws -> Branch {
        let pointer = try GitPointer(
            create: { git_branch_create($0, repository.pointer, name, commit.commit.pointer, 0) },
            free: git_reference_free)
        return try Branch(pointer)
    }

    public func branch(named name: String) throws -> Branch {
        let pointer = try GitPointer(
            create: { git_branch_lookup($0, repository.pointer, name, GIT_BRANCH_LOCAL) },
            free: git_reference_free)
        return try Branch(pointer)
    }
}

// MARK: - Reference

extension Repository {

    public func references() throws -> [Reference] {

        try GitIterator(
            createIterator: { git_reference_iterator_new($0, repository.pointer) },
            freeIterator: git_reference_iterator_free,
            nextElement: git_reference_next,
            freeElement: git_reference_free)
            .map(Reference.init)
    }
}

// MARK: - Remote Branch

extension Repository {

    public func remoteBranches() throws -> [RemoteBranch] {

        try GitIterator(
            createIterator: { git_branch_iterator_new($0, repository.pointer, GIT_BRANCH_REMOTE) },
            freeIterator: git_branch_iterator_free,
            nextElement: {
                let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
                defer { type.deallocate() }
                return git_branch_next($0, type, $1)
            },
            freeElement: git_reference_free)
            .map(RemoteBranch.init)
    }

    public func remoteBranch(named name: String) throws -> RemoteBranch {
        let pointer = try GitPointer(
            create: { git_branch_lookup($0, repository.pointer, name, GIT_BRANCH_REMOTE) },
            free: git_reference_free)
        return try RemoteBranch(pointer)
    }
}

// MARK: - Tag

extension Repository {

    public func tags() throws -> [Tag] {
        try references()
            .compactMap(\.tag)
    }
}

// MARK: - Object

extension Repository {

    public func object(for id: Object.ID) throws -> Object {
        var oid = id.oid
        let pointer = try GitPointer(create: { git_object_lookup($0, repository.pointer, &oid, GIT_OBJECT_ANY) },
                                     free: git_object_free)
        return try Object(pointer)
    }
}

// MARK: - Commits

public struct SortOptions: OptionSet {
    public let rawValue: UInt32
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
    private init(_ sort: git_sort_t) {
        self.init(rawValue: sort.rawValue)
    }
    public init() { self.init(GIT_SORT_NONE) }
    public static let time = Self(GIT_SORT_TIME)
    public static let topological = Self(GIT_SORT_TOPOLOGICAL)
    public static let reverse = Self(GIT_SORT_REVERSE)
}

extension Repository {

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
            createIterator: { git_revwalk_new($0, repository.pointer) },
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

// MARK: - Reflog

extension Repository {

    public func reflog() throws -> Reflog {
        let reflog = try GitPointer(create: { git_reflog_read($0, repository.pointer, "HEAD") },
                                    free: git_reflog_free)
        return Reflog(reflog: reflog)
    }
}
