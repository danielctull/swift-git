
import Clibgit2

public struct Branch {
    let branch: GitPointer
    public let objectID: ObjectID
    public let name: String
    public let fullName: String
}

extension Branch {

    init(_ branch: GitPointer) throws {
        guard branch.check(git_reference_is_branch) else { throw GitError(.unknown) }
        self.branch = branch
        name = try String(validatingUTF8: branch.get(git_branch_name))!
        objectID = ObjectID(branch.get(git_reference_target))
        fullName = String(validatingUTF8: branch.get(git_reference_name))!
    }
}
