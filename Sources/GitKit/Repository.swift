
import Clibgit2
import Foundation

public struct Repository {
    let repository: OpaquePointer
}

extension Repository {

    public init(url: URL) throws {
        repository = try OpaquePointer { repository in
            url.withUnsafeFileSystemRepresentation { path in
                git_repository_init(repository, path, 0)
            }
        }
    }
}
