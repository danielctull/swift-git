
import Clibgit2
import Foundation

public struct Repository {
    let repository: OpaquePointer
}

extension Repository {

    public init(url: URL) throws {
        var repository: OpaquePointer? = nil
        git_libgit2_init()
        let result = withUnsafeMutablePointer(to: &repository) { repository in
            url.withUnsafeFileSystemRepresentation { path in
                git_repository_init(repository, path, 0)
            }
        }
        if let error = GitError(result) { throw error }
        self.repository = repository!
    }
}
