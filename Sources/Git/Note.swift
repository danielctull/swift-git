
import Cgit2

// MARK: - Note

public struct Note: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public let id: ID
    public let reference: Reference.Name
    public let target: Object.ID

    @GitActor
    init(pointer: GitPointer) throws {
        pointer.assert(git_reference_is_note, "Expected note.")
        self.pointer = pointer
        reference = try Reference.Name(pointer: pointer)
        target = try Object.ID(reference: pointer)
        id = ID(name: reference)
    }
}

// MARK: - Branch.ID

extension Note {

    public struct ID: Equatable, Hashable, Sendable {
        fileprivate let name: Reference.Name
    }
}

extension Note.ID: CustomStringConvertible {
    public var description: String { name.description }
}

// MARK: - CustomDebugStringConvertible

extension Note: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Note(reference: \(reference), target: \(target.debugDescription))"
    }
}

// MARK: - GitPointerInitialization

extension Note: GitPointerInitialization {}
