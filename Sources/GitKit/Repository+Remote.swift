
import Clibgit2

extension Repository {

    public func remote(named name: String) throws -> Remote {
        let remote = try GitPointer(create: { git_remote_lookup($0, repository.pointer, name) },
                                    free: git_remote_free)
        return try Remote(remote)
    }
}
