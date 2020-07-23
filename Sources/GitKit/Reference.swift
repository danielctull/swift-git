
import Clibgit2

public enum Reference {
    case branch(Branch)
    case note(Note)
    case remoteBranch(RemoteBranch)
    case tag(Tag)
}

extension Reference {

    init(_ reference: GitPointer) throws {

        switch reference {

        case let reference where reference.check(git_reference_is_branch):
            self = try .branch(Branch(reference))

        case let reference where reference.check(git_reference_is_note):
            self = try .note(Note(reference))

        case let reference where reference.check(git_reference_is_remote):
            self = try .remoteBranch(RemoteBranch(reference))

        case let reference where reference.check(git_reference_is_tag):
            self = try .tag(Tag(reference))

        default:
            struct UnknownReferenceType: Error {}
            throw UnknownReferenceType()
        }
    }
}

extension Reference {

    var tag: Tag? {
        guard case .tag(let tag) = self else { return nil }
        return tag
    }
}
