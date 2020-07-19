
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

extension Repository {

    public func head() throws -> Reference {
        let head = try GitPointer(create: { git_repository_head($0, repository.pointer) },
                                  free: git_reference_free)
        return try Reference(head)
    }

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
