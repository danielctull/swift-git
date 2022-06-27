
import Clibgit2
import Tagged

extension Repository {

    public var branches: [Branch] {
        get throws {

            try GitIterator(
                createIterator: task(for: git_branch_iterator_new, GIT_BRANCH_LOCAL),
                freeIterator: git_branch_iterator_free,
                nextElement: {
                    let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
                    defer { type.deallocate() }
                    return git_branch_next($0, type, $1)
                },
                freeElement: git_reference_free)
                .map(Branch.init)
        }
    }

    public func createBranch(named name: String, at commit: Commit) throws -> Branch {
        try Branch(
            create: task(for: git_branch_create, name, commit.pointer.pointer, 0),
            free: git_reference_free)
    }

    public func branch(named name: String) throws -> Branch {
        try Branch(
            create: task(for: git_branch_lookup, name, GIT_BRANCH_LOCAL),
            free: git_reference_free)
    }

    public func delete(_ branch: Branch) throws {
        try branch.task(for: git_branch_delete)()
    }
}

// MARK: - Branch

public struct Branch: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<Branch, Reference.ID>
    public let id: ID
    public let target: Object.ID
    public let name: String

    init(pointer: GitPointer) throws {
        guard pointer.check(git_reference_is_branch) else { throw GitKitError.incorrectType(expected: "branch") }
        self.pointer = pointer
        id = try ID(reference: pointer)
        name = try Unwrap(String(validatingUTF8: pointer.get(git_branch_name)))
        target = try Object.ID(reference: pointer)
    }
}

extension Branch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Branch(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
}
