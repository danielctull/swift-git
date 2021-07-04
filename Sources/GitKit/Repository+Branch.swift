
import Cgit2

extension Repository {

    public func branches() throws -> [Branch] {

        try GitIterator(
            createIterator: { git_branch_iterator_new($0, repository.pointer, GIT_BRANCH_LOCAL) },
            freeIterator: git_branch_iterator_free,
            nextElement: {
                let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
                defer { type.deallocate() }
                return git_branch_next($0, type, $1)
            },
            freeElement: git_reference_free)
            .map(Branch.init)
    }

    public func createBranch(named name: String, at commit: Commit) throws -> Branch {
        let pointer = try GitPointer(
            create: { git_branch_create($0, repository.pointer, name, commit.commit.pointer, 0) },
            free: git_reference_free)
        return try Branch(pointer)
    }

    public func branch(named name: String) throws -> Branch {
        let pointer = try GitPointer(
            create: { git_branch_lookup($0, repository.pointer, name, GIT_BRANCH_LOCAL) },
            free: git_reference_free)
        return try Branch(pointer)
    }
}
