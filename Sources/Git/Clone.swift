import Foundation
import libgit2

extension Repository {

  /// Clone a remote repository.
  public static func clone(_ remote: URL, to local: URL) throws -> Repository {
    try remote.withUnsafeRepresentation { remote in
      try local.withUnsafeFileSystemRepresentation { local in
        try Repository(
          pointer: Managed(
            create: Create(git_clone, remote, local, nil),
            free: git_repository_free
          )
        )
      }
    }
  }
}

extension URL {
  fileprivate func withUnsafeRepresentation<Result>(
    _ body: (UnsafePointer<Int8>) throws -> Result
  ) rethrows -> Result {
    try (isFileURL ? path() : absoluteString).withCString(body)
  }
}
