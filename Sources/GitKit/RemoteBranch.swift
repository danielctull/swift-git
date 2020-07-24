
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
        name = try String(validatingUTF8: branch.get(git_branch_name))!
        objectID = try ObjectID(branch.get(git_reference_target))
    }
}
