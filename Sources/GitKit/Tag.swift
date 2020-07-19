
import Clibgit2

public struct Tag {
    let tag: GitPointer
    public let objectID: ObjectID
    public let fullName: String
}

extension Tag {

    init(_ reference: GitPointer) throws {
        guard reference.check(git_reference_is_tag) else { throw GitError(.unknown) }
        tag = reference
        objectID = ObjectID(reference.get(git_reference_target))
        fullName = String(validatingUTF8: reference.get(git_reference_name))!
    }
}
