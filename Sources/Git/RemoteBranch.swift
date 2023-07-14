
import Clibgit2

extension Repository {

    @GitActor
    public var remoteBranches: some Sequence<RemoteBranch> {
        get throws {
            try GitIterator {

                try GitPointer(
                    create: pointer.create(git_branch_iterator_new, GIT_BRANCH_REMOTE),
                    free: git_branch_iterator_free)

            } nextElement: { iterator in

                try RemoteBranch(
                    create: iterator.create(firstOutput(of: git_branch_next)),
                    free: git_reference_free)
            }
        }
    }

    @GitActor
    public func remoteBranch(on remote: Remote.ID, named branch: String) throws -> RemoteBranch {
        try (remote.rawValue + "/" + branch).withCString { name in
            try RemoteBranch(
                create: pointer.create(git_branch_lookup, name, GIT_BRANCH_REMOTE),
                free: git_reference_free)
        }
    }
}

// MARK: - RemoteBranch

public struct RemoteBranch: Equatable, Hashable, Sendable {

    let pointer: GitPointer
    public let id: ID
    public let target: Object.ID
    public let remote: Remote.ID
    public let name: String
    public let reference: Reference.Name

    @GitActor
    init(pointer: GitPointer) throws {
        pointer.assert(git_reference_is_remote, "Expected remote branch.")
        self.pointer = pointer
        reference = try Reference.Name(pointer: pointer)
        name = try pointer.get(git_branch_name) |> String.init
        target = try Object.ID(reference: pointer)
        remote = try Remote.ID(rawValue: String(Unwrap(name.split(separator: "/").first)))
        id = ID(name: reference)
    }
}

// MARK: - RemoteBranch.ID

extension RemoteBranch {

    public struct ID: Equatable, Hashable, Sendable {
        fileprivate let name: Reference.Name
    }
}

extension RemoteBranch.ID: CustomStringConvertible {
    public var description: String { name.description }
}

// MARK: - CustomDebugStringConvertible

extension RemoteBranch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "RemoteBranch(name: \(name), reference: \(reference), target: \(target.debugDescription))"
    }
}

// MARK: - GitPointerInitialization

extension RemoteBranch: GitPointerInitialization {}
