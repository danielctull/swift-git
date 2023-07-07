
import Clibgit2
import Tagged

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

public struct RemoteBranch: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public typealias ID = Tagged<RemoteBranch, Reference.ID>
    public let id: ID
    public let target: Object.ID
    public let remote: Remote.ID
    public let name: String

    @GitActor
    init(pointer: GitPointer) throws {
        pointer.assert(git_reference_is_remote, "Expected remote branch.")
        self.pointer = pointer
        id = try ID(reference: pointer)
        name = try pointer.get(git_branch_name) |> String.init
        target = try Object.ID(reference: pointer)
        remote = try Remote.ID(rawValue: String(Unwrap(name.split(separator: "/").first)))
    }
}

extension RemoteBranch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "RemoteBranch(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
}

// MARK: - GitPointerInitialization

extension RemoteBranch: GitPointerInitialization {}
