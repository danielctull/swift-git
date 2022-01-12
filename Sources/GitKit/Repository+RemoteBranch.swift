
import Clibgit2

extension Repository {

//    public var remoteBranches: [RemoteBranch] {
//        get throws {
//            try GitIterator(
//                createIterator: repository.create(git_branch_iterator_new, GIT_BRANCH_REMOTE),
//                freeIterator: git_branch_iterator_free,
//                nextElement: {
//                    let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
//                    defer { type.deallocate() }
//                    return git_branch_next($0, type, $1)
//                },
//                freeElement: git_reference_free)
//                .map(RemoteBranch.init)
//        }
//    }

    public func remoteBranch(on remote: Remote.ID, named branch: String) async throws -> RemoteBranch {
        let name = remote.rawValue + "/" + branch
        let pointer = try await GitPointer(
            create: repository.create(git_branch_lookup, name, GIT_BRANCH_REMOTE),
            free: git_reference_free)
        return try await RemoteBranch(pointer)
    }
}
