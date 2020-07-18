
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

extension Repository {

    public func head() throws -> Branch {
        let head = try OpaquePointer { git_repository_head($0, repository) }
        return try Branch(head)
    }
}
