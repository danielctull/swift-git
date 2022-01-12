
import Clibgit2
import Tagged

public struct RemoteBranch: Identifiable {
    let branch: GitPointer
    public typealias ID = Tagged<RemoteBranch, Reference.ID>
    public let id: ID
    public let target: Object.ID
    public let remote: Remote.ID
    public let name: String
}

extension RemoteBranch {

    init(_ branch: GitPointer) async throws {
        guard await branch.check(git_reference_is_remote) else { throw GitKitError.incorrectType(expected: "remote branch") }
        self.branch = branch
        id = try await ID(reference: branch)
        name = try await Unwrap(String(validatingUTF8: branch.get(git_branch_name)))
        target = try await Object.ID(reference: branch)
        remote = try Remote.ID(rawValue: String(Unwrap(name.split(separator: "/").first)))
    }
}

// MARK: - CustomDebugStringConvertible

extension RemoteBranch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "RemoteBranch(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
}
