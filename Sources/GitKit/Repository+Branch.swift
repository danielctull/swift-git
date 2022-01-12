
import Clibgit2

extension Repository {

//    public var branches: [Branch] {
//        get throws {
//
//            try GitIterator(
//                createIterator: repository.create(git_branch_iterator_new, GIT_BRANCH_LOCAL),
//                freeIterator: git_branch_iterator_free,
//                nextElement: {
//                    let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
//                    defer { type.deallocate() }
//                    return git_branch_next($0, type, $1)
//                },
//                freeElement: git_reference_free)
//                .map(Branch.init)
//        }
//    }

    public func createBranch(named name: String, at commit: Commit) async throws -> Branch {
        let pointer = try await GitPointer(
            create: repository.create(git_branch_create, name, commit.commit.pointer, 0),
            free: git_reference_free)
        return try await Branch(pointer)
    }

    public func branch(named name: String) async throws -> Branch {
        let pointer = try await GitPointer(
            create: repository.create(git_branch_lookup, name, GIT_BRANCH_LOCAL),
            free: git_reference_free)
        return try await Branch(pointer)
    }
}
