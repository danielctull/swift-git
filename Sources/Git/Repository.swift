import Foundation
import libgit2

// MARK: - Repository

public struct Repository: Equatable, Hashable {
  let pointer: Managed<OpaquePointer>
}

extension Repository {

  public enum Options: Sendable {
    case create(isBare: Bool)

    public static let create = Self.create(isBare: false)
  }

  public init(url: URL, options: Options = .create) throws {
    pointer = try Managed(
      create: .init { pointer in
        url.withUnsafeFileSystemRepresentation { path in
          switch options {
          case .create(let isBare):
            return git_repository_init(pointer, path, UInt32(isBare))
          }
        }

      },
      free: git_repository_free
    )
  }

  public static func open(_ url: URL) throws -> Repository {
    try Repository(
      pointer: Managed(
        create: Managed.Create { pointer in
          url.withUnsafeFileSystemRepresentation { path in
            git_repository_open(pointer, path)
          }
        },
        free: git_repository_free
      )
    )
  }
}

extension Repository {

  /// Get the `URL` of the shared common directory for this repository.
  ///
  /// If the repository is bare, it is the root directory for the repository.
  ///
  /// If the repository is a worktree, it is the parent repo’s git directory.
  ///
  /// Otherwise, it is the git directory.
  public var gitDirectory: URL {
    get throws {
      try pointer.get(git_repository_commondir)
        |> Unwrap
        |> String.init(cString:)
        |> URL.init(fileURLWithPath:)
    }
  }

  public var workingDirectory: URL? {
    try? pointer.get(git_repository_workdir)
      |> Unwrap
      |> String.init(cString:)
      |> URL.init(fileURLWithPath:)
  }
}
