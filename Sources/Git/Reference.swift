
import Clibgit2

extension Repository {

    /// Retrieve and resolve the reference pointed at by HEAD.
    @GitActor
    public var head: Reference {
        get throws {
            try Reference(
                create: pointer.create(git_repository_head),
                free: git_reference_free)
        }
    }

    @GitActor
    public var references: some Sequence<Reference> {
        get throws {
            try GitIterator {

                try GitPointer(
                    create: pointer.create(git_reference_iterator_new),
                    free: git_reference_iterator_free)

            } nextElement: { iterator in

                try Reference(
                    create: iterator.create(git_reference_next),
                    free: git_reference_free)
            }
        }
    }

    /// Lookup a reference by id in a repository.
    @GitActor
    public func reference(for id: Reference.ID) throws -> Reference {
        try id.name.withCString { id in
            try Reference(
                create: pointer.create(git_reference_lookup, id),
                free: git_reference_free)
        }
    }

    /// Delete an existing reference by id.
    ///
    /// This method removes the reference from the repository without looking at
    /// its old value.
    @GitActor
    public func remove(_ id: Reference.ID) throws {
        try remove(reference(for: id))
    }

    /// Delete an existing reference.
    ///
    /// This method removes the reference from the repository without looking at
    /// its old value.
    @GitActor
    public func remove(_ reference: Reference) throws {
        try reference.id.name.rawValue.withCString { id in
            try pointer.perform(git_reference_remove, id)
        }
    }

    @GitActor
    public func delete(_ reference: Reference) throws {
        try reference.pointer.perform(git_reference_delete)
    }
}

// MARK: - Reference

public enum Reference: Equatable, Hashable {
    case branch(Branch)
    case note(Note)
    case remoteBranch(RemoteBranch)
    case tag(Tag)
}

extension Reference: Sendable {

    var pointer: GitPointer {
        switch self {
        case .branch(let branch): return branch.pointer
        case .note(let note): return note.pointer
        case .remoteBranch(let remoteBranch): return remoteBranch.pointer
        case .tag(let tag): return tag.pointer
        }
    }

    @GitActor
    init(pointer: GitPointer) throws {

        switch pointer {

        case let pointer where pointer.get(git_reference_is_branch) |> Bool.init:
            self = try .branch(Branch(pointer: pointer))

        case let pointer where pointer.get(git_reference_is_note) |> Bool.init:
            self = try .note(Note(pointer: pointer))

        case let pointer where pointer.get(git_reference_is_remote) |> Bool.init:
            self = try .remoteBranch(RemoteBranch(pointer: pointer))

        case let pointer where pointer.get(git_reference_is_tag) |> Bool.init:
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

// MARK: - Identifiable

extension Reference {

    public struct ID: Equatable, Hashable, Sendable {
        let name: Name
    }
}

extension Reference.ID: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(name: Reference.Name(value))
    }
}

extension Reference.ID: CustomStringConvertible {

    public var description: String { name.description }
}

extension Reference: Identifiable {

    public var id: ID {
        switch self {
        case let .branch(branch): return ID(name: branch.reference)
        case let .note(note): return ID(name: note.reference)
        case let .remoteBranch(remoteBranch): return ID(name: remoteBranch.reference)
        case let .tag(tag): return ID(name: tag.reference)
        }
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

// MARK: - Name

extension Reference {

    /// The full name of a reference.
    public struct Name: Equatable, Hashable, Sendable {
        let rawValue: String

        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension Reference.Name: CustomStringConvertible {

    public var description: String { rawValue }
}

extension Reference.Name {

    fileprivate func withCString<Result>(
        _ body: (UnsafePointer<Int8>) throws -> Result
    ) rethrows -> Result {
        try rawValue.withCString(body)
    }
}

extension Reference.Name {

    @GitActor
    init(pointer: GitPointer) throws {
        try self.init(pointer.get(git_reference_name) |> Unwrap |> String.init(cString:))
    }
}

// MARK: - GitPointerInitialization

extension Reference: GitPointerInitialization {}
