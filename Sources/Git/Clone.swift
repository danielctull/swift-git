import Foundation
import libgit2

extension Repository {

  /// Clone a remote repository.
  public static func clone(_ remote: URL, to local: URL) throws -> Repository {
    let remoteString = remote.isFileURL ? remote.path : remote.absoluteString
    return Repository(
      pointer: try Managed(
        create: Managed.Create { pointer in
          local.withUnsafeFileSystemRepresentation { path in
            git_clone(pointer, remoteString, path, nil)
          }
        },
        free: git_repository_free
      )
    )
  }
}
