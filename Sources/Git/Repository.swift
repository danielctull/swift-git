
import Clibgit2
import Foundation

// MARK: - Repository

public struct Repository: GitReference {

    let pointer: GitPointer

    init(pointer: GitPointer) throws {
        self.pointer = pointer
    }
}

extension Repository {

    public enum Options {
        case open
        case create(isBare: Bool)

        public static let create = Self.create(isBare: false)
    }

    public init(url: URL, options: Options = .create) throws {
        pointer = try GitPointer(create: GitTask { pointer in
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

        pointer = try GitPointer(create: GitTask { pointer in
            local.withUnsafeFileSystemRepresentation { path in
                git_clone(pointer, remoteString, path, nil)
            }
        }, free: git_repository_free)
    }

    public var workingDirectory: URL? {
        try? pointer.get(git_repository_workdir)
            |> Unwrap
            |> String.init(validatingUTF8:)
            |> Unwrap
            |> URL.init(fileURLWithPath:)
    }
}

extension Repository: CustomStringConvertible {

    public var description: String { "Repository" }
}
