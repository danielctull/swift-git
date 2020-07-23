
import Clibgit2
import Tagged

public struct Tag: Identifiable {
    let tag: GitPointer
    public typealias ID = Tagged<Tag, Reference.ID>
    public let id: ID
    public let objectID: ObjectID
}

extension Tag {

    public var name: String {
        String(id.dropFirst(10)) // length of "refs/tags/"
    }
}

extension Tag {

    init(_ reference: GitPointer) throws {
        guard reference.check(git_reference_is_tag) else { throw GitKitError.incorrectType(expected: "tag") }
        tag = reference
        id = ID(rawValue: Reference.ID(reference: reference))
        objectID = ObjectID(reference.get(git_reference_target))
    }
}
