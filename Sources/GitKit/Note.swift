
import Clibgit2
import Tagged

// MARK: - Note

public struct Note: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<Note, Reference.ID>
    public let id: ID
    public let target: Object.ID

    init(pointer: GitPointer) throws {
        guard pointer.check(git_reference_is_note) else { throw GitKitError.incorrectType(expected: "note") }
        self.pointer = pointer
        id = try ID(reference: pointer)
        target = try Object.ID(reference: pointer)
    }
}

extension Note: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Note(id: \(id), target: \(target.debugDescription))"
    }
}
