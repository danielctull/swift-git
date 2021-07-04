
import Cgit2
import Foundation

// MARK: - Repository

public struct Repository: Equatable, Hashable, Sendable {
    let pointer: GitPointer
}

extension Repository {

    public enum Options: Sendable {
        case open
        case create(isBare: Bool)

        public static let create = Self.create(isBare: false)
    }

    @GitActor
    public init(url: URL, options: Options = .create) throws {
        pointer = try GitPointer { pointer in
            url.withUnsafeFileSystemRepresentation { path in
                switch options {
                case .open:               return git_repository_open(pointer, path)
                case .create(let isBare): return git_repository_init(pointer, path, UInt32(isBare))
                }
            }
        } free: {
            git_repository_free($0)
        }
    }

    @GitActor
    public init(local: URL, remote: URL) throws {
        let remoteString = remote.isFileURL ? remote.path : remote.absoluteString
        pointer = try GitPointer { pointer in
            local.withUnsafeFileSystemRepresentation { path in
                git_clone(pointer, remoteString, path, nil)
            }
        } free: {
            git_repository_free($0)
        }
    }

    /// Get the `URL` of the shared common directory for this repository.
    ///
    /// If the repository is bare, it is the root directory for the repository.
    ///
    /// If the repository is a worktree, it is the parent repo’s git directory.
    ///
    /// Otherwise, it is the git directory.
    @GitActor
    public var gitDirectory: URL {
        get throws {
            try pointer.get(git_repository_commondir)
                |> Unwrap
                |> String.init(cString:)
                |> URL.init(fileURLWithPath:)
        }
    }

    @GitActor
    public var workingDirectory: URL? {
        try? pointer.get(git_repository_workdir)
            |> Unwrap
            |> String.init(cString:)
            |> URL.init(fileURLWithPath:)
    }
}

// MARK: - GitPointerInitialization

extension Repository: GitPointerInitialization {}
