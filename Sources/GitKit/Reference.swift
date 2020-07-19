
import Clibgit2

public enum Reference {
    case branch(Branch)
    case note
    case remoteBranch
    case tag
}

extension Reference {

    init(_ reference: GitPointer) throws {

        if reference.check(git_reference_is_branch) {
            self = .branch(try Branch(reference))
            return
        } else if reference.check(git_reference_is_note) {
            self = .note
            return
        } else if reference.check(git_reference_is_remote) {
            self = .remoteBranch
            return
        } else if reference.check(git_reference_is_tag) {
            self = .tag
            return
        }

        struct UnknownReferenceType: Error {}
        throw UnknownReferenceType()
    }
}
