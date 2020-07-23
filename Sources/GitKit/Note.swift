
import Clibgit2
import Tagged

public struct Note: Identifiable {
    public typealias ID = Tagged<Note, Reference.ID>
    public let id: ID
}

extension Note {

    init(_ note: GitPointer) throws {
        guard note.check(git_reference_is_note) else { throw GitKitError.incorrectType(expected: "note") }
        id = ID(rawValue: Reference.ID(reference: note))
    }
}
