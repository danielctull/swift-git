
import Clibgit2
import Foundation

// MARK: - Repository

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

    public var workingDirectory: URL? {
        guard let path = try? String(validatingUTF8: repository.get(git_repository_workdir)) else { return nil }
        return URL(fileURLWithPath: path)
    }
}

extension Repository: CustomStringConvertible {

    public var description: String { "Repository" }
}

extension Repository {

    init(_ pointer: GitPointer) {
        repository = pointer
    }
}
