
import Clibgit2
import Tagged

public struct RemoteBranch {
    let branch: GitPointer
    public typealias ID = Tagged<RemoteBranch, Reference.ID>
    public let id: ID
    public let objectID: ObjectID
    public let name: String
}

extension RemoteBranch {

    init(_ branch: GitPointer) throws {
        guard branch.check(git_reference_is_remote) else { throw GitKitError.incorrectType(expected: "remote branch") }
        self.branch = branch
        id = try ID(rawValue: Reference.ID(reference: branch))
        name = try Unwrap(String(validatingUTF8: branch.get(git_branch_name)))
        objectID = try ObjectID(reference: branch)
    }
}

// MARK: - CustomDebugStringConvertible

extension RemoteBranch: CustomDebugStringConvertible {
    public var debugDescription: String {
        "RemoteBranch(name: \(name), id: \(id), objectID: \(objectID.debugDescription))"
    }
}
