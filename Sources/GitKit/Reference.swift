
import Clibgit2
import Tagged

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

// Object.ID

extension Reference {

    public var objectID: Object.ID {
        switch self {
        case let .branch(branch): return branch.objectID
        case let .note(note): return note.objectID
        case let .remoteBranch(remoteBranch): return remoteBranch.objectID
        case let .tag(tag): return tag.target
        }
    }
}

// Reference.ID

extension Reference: Identifiable {

    public typealias ID = Tagged<Reference, String>

    public var id: ID {
        switch self {
        case let .branch(branch): return branch.id.rawValue
        case let .note(note): return note.id.rawValue
        case let .remoteBranch(remoteBranch): return remoteBranch.id.rawValue
        case let .tag(tag): return tag.id.rawValue
        }
    }
}

// Getters

extension Reference {

    var tag: Tag? {
        guard case .tag(let tag) = self else { return nil }
        return tag
    }
}

// MARK: - CustomDebugStringConvertible

extension Reference: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case let .branch(branch): return branch.debugDescription
        case let .note(note): return note.debugDescription
        case let .remoteBranch(remoteBranch): return remoteBranch.debugDescription
        case let .tag(tag): return tag.debugDescription
        }
    }
}

// MARK: - Tagged + Reference.ID

extension Tagged where RawValue == Reference.ID {

    init(reference: GitPointer) throws {
        let name = try Unwrap(String(validatingUTF8: reference.get(git_reference_name)))
        let referenceID = Reference.ID(rawValue: name)
        self.init(rawValue: referenceID)
    }
}
