
import Clibgit2
import Tagged

public struct RemoteBranch {
    let branch: GitPointer
    public typealias ID = Tagged<RemoteBranch, String>
    public let id: ID
    public let objectID: ObjectID
    public let name: String
}

extension RemoteBranch {

    init(_ branch: GitPointer) throws {
        guard branch.check(git_reference_is_remote) else { throw GitError(.unknown) }
        self.branch = branch
        id = ID(rawValue: String(validatingUTF8: branch.get(git_reference_name))!)
        name = try String(validatingUTF8: branch.get(git_branch_name))!
        objectID = ObjectID(branch.get(git_reference_target))
    }
}
