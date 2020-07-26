
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
        id = try ID(rawValue: Reference.ID(reference: reference))
        objectID = try ObjectID(reference: reference)
    }
}

// MARK: - CustomDebugStringConvertible

extension Tag: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tag(name: \(name), id: \(id), objectID: \(objectID.debugDescription))"
    }
}
