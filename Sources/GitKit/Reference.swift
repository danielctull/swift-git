
import Clibgit2

public enum Reference {
    case branch(Branch)
    case note
    case remoteBranch
    case tag
}

extension Reference {

    init(_ reference: GitPointer) throws {

        if git_reference_is_branch(reference.pointer) == .true {
            self = .branch(try Branch(reference))
        } else if git_reference_is_note(reference.pointer) == .true {
            self = .note
        } else if git_reference_is_remote(reference.pointer) == .true {
            self = .remoteBranch
        } else if git_reference_is_tag(reference.pointer) == .true {
            self = .tag
        }

        struct UnknownReferenceType: Error {}
        throw UnknownReferenceType()
    }
}
