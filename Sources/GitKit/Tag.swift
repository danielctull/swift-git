
import Clibgit2
import Tagged

public struct Tag: Identifiable {
    let tag: GitPointer
    public typealias ID = Tagged<Tag, String>
    public let id: ID
    public let objectID: ObjectID
}

extension Tag {

    public var name: String {
        String(id.rawValue.dropFirst(10)) // length of "refs/tags/"
    }
}

extension Tag {

    init(_ reference: GitPointer) throws {
        guard reference.check(git_reference_is_tag) else { throw GitError(.unknown) }
        tag = reference
        id = ID(rawValue: String(validatingUTF8: reference.get(git_reference_name))!)
        objectID = ObjectID(reference.get(git_reference_target))
    }
}
