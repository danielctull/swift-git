
import Clibgit2
import Tagged

extension Repository {

    public var branches: [Branch] {
        get throws {

            try GitIterator(
                createIterator: repository.create(git_branch_iterator_new, GIT_BRANCH_LOCAL),
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
        let pointer = try GitPointer(
            create: repository.create(git_branch_create, name, commit.commit.pointer, 0),
            free: git_reference_free)
        return try Branch(pointer)
    }

    public func branch(named name: String) throws -> Branch {
        let pointer = try GitPointer(
            create: repository.create(git_branch_lookup, name, GIT_BRANCH_LOCAL),
            free: git_reference_free)
        return try Branch(pointer)
    }
}

// MARK: - Branch

public struct Branch: Identifiable {
    let branch: GitPointer
    public typealias ID = Tagged<Branch, Reference.ID>
    public let id: ID
    public let target: Object.ID
    public let name: String
}

extension Branch {

    init(_ branch: GitPointer) throws {
        guard branch.check(git_reference_is_branch) else { throw GitKitError.incorrectType(expected: "branch") }
        self.branch = branch
        id = try ID(reference: branch)
        name = try Unwrap(String(validatingUTF8: branch.get(git_branch_name)))
        target = try Object.ID(reference: branch)
    }
}

extension Branch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Branch(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
}
