
import Clibgit2
import Tagged

public struct Branch: Identifiable {
    let branch: GitPointer
    public typealias ID = Tagged<Branch, String>
    public let id: ID
    public let objectID: ObjectID
    public let name: String
}

extension Branch {

    init(_ branch: GitPointer) throws {
        guard branch.check(git_reference_is_branch) else { throw GitError(.unknown) }
        self.branch = branch
        id = ID(rawValue: String(validatingUTF8: branch.get(git_reference_name))!)
        name = try String(validatingUTF8: branch.get(git_branch_name))!
        objectID = ObjectID(branch.get(git_reference_target))
    }
}
