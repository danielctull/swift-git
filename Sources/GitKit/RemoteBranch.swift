
import Clibgit2
import Tagged

extension Repository {

    public var remoteBranches: [RemoteBranch] {
        get throws {
            try GitIterator(
                createIterator: create(git_branch_iterator_new, GIT_BRANCH_REMOTE),
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

    public func remoteBranch(on remote: Remote.ID, named branch: String) throws -> RemoteBranch {
        let name = remote.rawValue + "/" + branch
        let pointer = try GitPointer(
            create: create(git_branch_lookup, name, GIT_BRANCH_REMOTE),
            free: git_reference_free)
        return try RemoteBranch(pointer: pointer)
    }
}

// MARK: - RemoteBranch

public struct RemoteBranch: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<RemoteBranch, Reference.ID>
    public let id: ID
    public let target: Object.ID
    public let remote: Remote.ID
    public let name: String

    init(pointer: GitPointer) throws {
        guard pointer.check(git_reference_is_remote) else { throw GitKitError.incorrectType(expected: "remote branch") }
        self.pointer = pointer
        id = try ID(reference: pointer)
        name = try Unwrap(String(validatingUTF8: pointer.get(git_branch_name)))
        target = try Object.ID(reference: pointer)
        remote = try Remote.ID(rawValue: String(Unwrap(name.split(separator: "/").first)))
    }
}

extension RemoteBranch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "RemoteBranch(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
}
