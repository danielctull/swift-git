
import Clibgit2

public struct RemoteBranch {
    let branch: GitPointer
    public let objectID: ObjectID
    public let name: String
    public let fullName: String
}

extension RemoteBranch {

    init(_ branch: GitPointer) throws {
        guard branch.check(git_reference_is_remote) else { throw GitError(.unknown) }
        self.branch = branch
        name = try String(validatingUTF8: branch.get(git_branch_name))!
        objectID = ObjectID(branch.get(git_reference_target))
        fullName = String(validatingUTF8: branch.get(git_reference_name))!
    }
}
