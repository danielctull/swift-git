
import Clibgit2
import Foundation

public struct Repository {
    let pointer: OpaquePointer
}

extension Repository {

    public init(url: URL) throws {
        pointer = try OpaquePointer { repository in
            url.withUnsafeFileSystemRepresentation { path in
                git_repository_init(repository, path, 0)
            }
        }
    }
}


// MARK: - Status

extension Status {

    public init(for repository: Repository) throws {

        let options = UnsafeMutablePointer<git_status_options>.allocate(capacity: 1)
        let result = git_status_options_init(options, UInt32(GIT_STATUS_OPTIONS_VERSION))
        if let error = GitError(result) { throw error }
        let list = try OpaquePointer { git_status_list_new($0, repository.pointer, options) }
        let count = git_status_list_entrycount(list)

        for index in 0..<count {
            let entry = git_status_byindex(list, index)
        }
        

        

    }

}
