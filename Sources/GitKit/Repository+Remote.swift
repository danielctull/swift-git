
import Clibgit2

extension Repository {

    public func remote(for id: Remote.ID) throws -> Remote {
        let remote = try GitPointer(create: { git_remote_lookup($0, repository.pointer, id.rawValue) },
                                    free: git_remote_free)
        return try Remote(remote)
    }
}
