
import Clibgit2

extension Repository {

    public func blame(for path: FilePath) throws -> Blame {
        let blame = try GitPointer(
            create: { git_blame_file($0, repository.pointer, path.rawValue, nil) },
            free: git_blame_free)
        return try Blame(blame)
    }
}
