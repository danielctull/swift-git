import Foundation
import libgit2

extension Repository {

  public init(local: URL, remote: URL) throws {
    let remoteString = remote.isFileURL ? remote.path : remote.absoluteString
    pointer = try Managed(
      create: .init { pointer in
        local.withUnsafeFileSystemRepresentation { path in
          git_clone(pointer, remoteString, path, nil)
        }
      },
      free: git_repository_free
    )
  }
}
