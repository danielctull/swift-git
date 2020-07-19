
import Clibgit2
import Foundation

public struct Repository {
    let repository: GitPointer
}

extension Repository {

    public init(url: URL) throws {
        repository = try GitPointer(create: { pointer in
            url.withUnsafeFileSystemRepresentation { path in
                git_repository_init(pointer, path, 0)
            }
        }, free: git_repository_free)
    }
}

extension Repository {

    public func head() throws -> Reference {
        let head = try GitPointer(create: { git_repository_head($0, repository.pointer) },
                                  free: git_reference_free)
        return try Reference(head)
    }
}
