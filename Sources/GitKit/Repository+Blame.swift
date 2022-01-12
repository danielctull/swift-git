
import Clibgit2

extension Repository {

    public func blame(for path: FilePath) async throws -> Blame {
        let blame = try await GitPointer(
            create: repository.create(git_blame_file, path.rawValue, nil),
            free: git_blame_free)
        return try Blame(blame)
    }
}
