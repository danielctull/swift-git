
import Clibgit2

extension Repository {

    public func remoteBranches() throws -> [RemoteBranch] {

        try GitIterator(
            createIterator: { git_branch_iterator_new($0, repository.pointer, GIT_BRANCH_REMOTE) },
            freeIterator: git_branch_iterator_free,
            nextElement: {
                let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
                defer { type.deallocate() }
                return git_branch_next($0, type, $1)
            },
            freeElement: git_reference_free)
            .map(RemoteBranch.init)
    }

    public func remoteBranch(on remote: Remote.ID, named branch: String) throws -> RemoteBranch {
        let name = remote.rawValue + "/" + branch
        let pointer = try GitPointer(
            create: { git_branch_lookup($0, repository.pointer, name, GIT_BRANCH_REMOTE) },
            free: git_reference_free)
        return try RemoteBranch(pointer)
    }
}
