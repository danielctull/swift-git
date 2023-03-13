
import Clibgit2
import Tagged

extension Repository {

    public var head: Reference {
        get throws {
            try Reference(
                create: pointer.get(git_repository_head),
                free: git_reference_free)
        }
    }

    public var references: [Reference] {
        get throws {
            try GitIterator(
                createIterator: pointer.get(git_reference_iterator_new),
                freeIterator: git_reference_iterator_free,
                nextElement: git_reference_next,
                freeElement: git_reference_free)
                .map(Reference.init)
        }
    }

    public func reference(for id: Reference.ID) throws -> Reference {
        try Reference(
            create: pointer.get(git_reference_lookup, id.rawValue),
            free: git_reference_free)
    }

    @available(iOS 13, *)
    @available(macOS 10.15, *)
    public func remove<SomeReference>(
        _ reference: SomeReference
    ) throws where SomeReference: Identifiable,
                   SomeReference.ID: RawRepresentable,
                   SomeReference.ID.RawValue == Reference.ID {
        try remove(reference.id.rawValue)
    }

    public func remove<ID>(
        _ id: ID
    ) throws where ID: RawRepresentable, ID.RawValue == Reference.ID {
        try remove(id.rawValue)
    }

    public func remove(_ id: Reference.ID) throws {
        try remove(reference(for: id))
    }

    public func remove(_ reference: Reference) throws {
        try pointer.perform(git_reference_remove, reference.id.rawValue)
    }
}

// MARK: - Reference

public enum Reference {
    case branch(Branch)
    case note(Note)
    case remoteBranch(RemoteBranch)
    case tag(Tag)
}

extension Reference: GitReference {

    var pointer: GitPointer {
        switch self {
        case .branch(let branch): return branch.pointer
        case .note(let note): return note.pointer
        case .remoteBranch(let remoteBranch): return remoteBranch.pointer
        case .tag(let tag): return tag.pointer
        }
    }

    init(pointer: GitPointer) throws {

        switch pointer {

        case let pointer where pointer.check(git_reference_is_branch):
            self = try .branch(Branch(pointer: pointer))

        case let pointer where pointer.check(git_reference_is_note):
            self = try .note(Note(pointer: pointer))

        case let pointer where pointer.check(git_reference_is_remote):
            self = try .remoteBranch(RemoteBranch(pointer: pointer))

        case let pointer where pointer.check(git_reference_is_tag):
            self = try .tag(Tag(pointer: pointer))

        default:
            struct UnknownReferenceType: Error {}
            throw UnknownReferenceType()
        }
    }
}

extension Reference {

    public var target: Object.ID {
        switch self {
        case let .branch(branch): return branch.target
        case let .note(note): return note.target
        case let .remoteBranch(remoteBranch): return remoteBranch.target
        case let .tag(tag): return tag.target
        }
    }
}

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

extension Reference {

    var tag: Tag? {
        guard case .tag(let tag) = self else { return nil }
        return tag
    }
}

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
        let name = try reference.get(git_reference_name) |> String.init
        let referenceID = Reference.ID(rawValue: name)
        self.init(rawValue: referenceID)
    }
}

extension Tagged where RawValue == String {
    // swiftlint:disable implicitly_unwrapped_optional
    init(_ utf8: UnsafePointer<Int8>!) throws {
    // swiftlint:enable implicitly_unwrapped_optional
        let value = try Unwrap(String(validatingUTF8: utf8))
        self.init(rawValue: value)
    }
}
