
import Clibgit2

public enum Reference {
    case branch(Branch)
    case note
    case remoteBranch
    case tag
}

extension Reference {

    init(_ pointer: OpaquePointer) throws {

        if git_reference_is_branch(pointer).isTrue {
            self = .branch(try Branch(pointer))
        } else if git_reference_is_note(pointer).isTrue {
            self = .note
        } else if git_reference_is_remote(pointer).isTrue {
            self = .remoteBranch
        } else if git_reference_is_tag(pointer).isTrue {
            self = .tag
        }

        struct UnknownReferenceType: Error {}
        throw UnknownReferenceType()
    }
}
