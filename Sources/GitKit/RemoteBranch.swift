
import Clibgit2
import Tagged

extension Repository {

    @GitActor
    public var remoteBranches: [RemoteBranch] {
        get throws {
            try GitIterator(
                createIterator: repository.create(git_branch_iterator_new, GIT_BRANCH_REMOTE),
                freeIterator: git_branch_iterator_free,
                nextElement: {
                    let type = UnsafeMutablePointer<git_branch_t>.allocate(capacity: 1)
                    defer { type.deallocate() }
                    return git_branch_next($0, type, $1)
                },
                freeElement: git_reference_free)
                .map(RemoteBranch.init)
        }
    }

    @GitActor
    public func remoteBranch(on remote: Remote.ID, named branch: String) throws -> RemoteBranch {
        let name = remote.rawValue + "/" + branch
        let pointer = try GitPointer(
            create: repository.create(git_branch_lookup, name, GIT_BRANCH_REMOTE),
            free: git_reference_free)
        return try RemoteBranch(pointer)
    }
}

// MARK: - RemoteBranch

public struct RemoteBranch: Identifiable {
    let branch: GitPointer
    public typealias ID = Tagged<RemoteBranch, Reference.ID>
    public let id: ID
    public let target: Object.ID
    public let remote: Remote.ID
    public let name: String
}

extension RemoteBranch {

    @GitActor
    init(_ branch: GitPointer) throws {
        guard branch.check(git_reference_is_remote) else { throw GitKitError.incorrectType(expected: "remote branch") }
        self.branch = branch
        id = try ID(reference: branch)
        name = try Unwrap(String(validatingUTF8: branch.get(git_branch_name)))
        target = try Object.ID(reference: branch)
        remote = try Remote.ID(rawValue: String(Unwrap(name.split(separator: "/").first)))
    }
}

extension RemoteBranch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "RemoteBranch(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
}
