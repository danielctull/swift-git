
import Clibgit2

public struct Branch {
    let branch: GitPointer
    public let name: String
}

extension Branch {

    init(_ branch: GitPointer) throws {
        guard git_reference_is_branch(branch.pointer).isTrue else { throw GitError(.unknown) }
        let name = try UnsafePointer<Int8> { git_branch_name($0, branch.pointer) }
        self.name = String(validatingUTF8: name)!
        self.branch = branch
    }
}
