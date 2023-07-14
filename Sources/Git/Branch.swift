
import Clibgit2

extension Repository {

    @GitActor
    public var branches: some Sequence<Branch> {
        get throws {
            try GitIterator {

                try GitPointer(
                    create: pointer.create(git_branch_iterator_new, GIT_BRANCH_LOCAL),
                    free: git_branch_iterator_free)

            } nextElement: { iterator in

                try Branch(
                    create: iterator.create(firstOutput(of: git_branch_next)),
                    free: git_reference_free)
            }
        }
    }

    @GitActor
    public func createBranch(named name: String, at commit: Commit) throws -> Branch {
        try name.withCString { name in
            try Branch(
                create: pointer.create(git_branch_create, name, commit.pointer.pointer, 0),
                free: git_reference_free
            )
        }
    }

    @GitActor
    public func branch(named name: String) throws -> Branch {
        try name.withCString { name in
            try Branch(
                create: pointer.create(git_branch_lookup, name, GIT_BRANCH_LOCAL),
                free: git_reference_free)
        }
    }

    @GitActor
    public func delete(_ branch: Branch) throws {
        try branch.pointer.perform(git_branch_delete)
    }
}

// MARK: - Branch

public struct Branch: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public let id: ID
    public let target: Object.ID
    public let name: String
    public let reference: Reference.Name

    @GitActor
    init(pointer: GitPointer) throws {
        pointer.assert(git_reference_is_branch, "Expected branch.")
        self.pointer = pointer
        name = try pointer.get(git_branch_name) |> String.init
        target = try Object.ID(reference: pointer)
        reference = try Reference.Name(pointer: pointer)
        id = ID(name: reference)
    }
}

extension Branch {

    @GitActor
    public func move(to name: String, force: Bool = false) throws -> Branch {
        try name.withCString { name in
            try Branch(
                create: pointer.create(git_branch_move, name, Int32(force)),
                free: git_reference_free)
        }
    }
}

// MARK: - Branch.ID

extension Branch {

    public struct ID: Equatable, Hashable, Sendable {
        fileprivate let name: Reference.Name
    }
}

extension Branch.ID: CustomStringConvertible {
    public var description: String { name.description }
}

// MARK: - CustomDebugStringConvertible

extension Branch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Branch(name: \(name), reference: \(reference), target: \(target.debugDescription))"
    }
}

// MARK: - GitPointerInitialization

extension Branch: GitPointerInitialization {}
