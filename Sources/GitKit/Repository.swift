
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
