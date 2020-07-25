
import Clibgit2
import Tagged

public struct Note: Identifiable {
    public typealias ID = Tagged<Note, Reference.ID>
    public let id: ID
    public let objectID: ObjectID
}

extension Note {

    init(_ note: GitPointer) throws {
        guard note.check(git_reference_is_note) else { throw GitKitError.incorrectType(expected: "note") }
        id = try ID(rawValue: Reference.ID(reference: note))
        objectID = try ObjectID(note.get(git_reference_target))
    }
}

// MARK: - CustomDebugStringConvertible

extension Note: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Note(id: \(id), objectID: \(objectID.debugDescription))"
    }
}
