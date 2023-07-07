
import Clibgit2
import Tagged

// MARK: - Note

public struct Note: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public typealias ID = Tagged<Note, Reference.ID>
    public let id: ID
    public let target: Object.ID

    @GitActor
    init(pointer: GitPointer) throws {
        pointer.assert(git_reference_is_note, "Expected note.")
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

// MARK: - GitPointerInitialization

extension Note: GitPointerInitialization {}
