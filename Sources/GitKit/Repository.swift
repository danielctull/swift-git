
import Clibgit2
import Foundation

public struct Repository {
    let repository: GitPointer
}

extension Repository {

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

    public func branch(named name: String) throws -> Branch {
        let pointer = try GitPointer(
            create: { git_branch_lookup($0, repository.pointer, name, GIT_BRANCH_LOCAL) },
            free: git_reference_free)
        return try Branch(pointer)
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

        try GitIterator(
            createIterator: { git_reference_iterator_new($0, repository.pointer) },
            freeIterator: git_reference_iterator_free,
            nextElement: git_reference_next,
            freeElement: git_reference_free)
            .map(Reference.init)
            .compactMap(\.tag)
    }
}

// MARK: - Commits

extension Repository {

    public func commits(in branch: Branch) throws -> [Commit] {

        try GitIterator(
            createIterator: { iterator in
                var result = git_revwalk_new(iterator, repository.pointer)
                if LibGit2Error(result) != nil { return result }
                result = git_revwalk_sorting(iterator.pointee, GIT_SORT_TIME.rawValue)
                if LibGit2Error(result) != nil { return result }
                var oid = branch.objectID.oid
                return git_revwalk_push(iterator.pointee, &oid)
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
