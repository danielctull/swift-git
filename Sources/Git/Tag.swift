
import Clibgit2
import Tagged

extension Repository {

    @GitActor
    public func tag(named name: String) throws -> Tag {
        try tags.first(where: { $0.name == name })
            ?? { throw GitError(.notFound) }()
    }

    @GitActor
    public var tags: [Tag] {
        get throws {
            try references.compactMap(\.tag)
        }
    }
}

// MARK: - Tag

public struct Tag: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    let kind: Kind
    public let id: ID
    public let reference: Reference.Name

    @GitActor
    init(pointer: GitPointer) throws {
        pointer.assert(git_reference_is_tag, "Expected tag.")
        self.pointer = pointer
        reference = try Reference.Name(pointer: pointer)
        id = ID(name: reference)

        let target = try Object.ID(reference: pointer)

        let repository = try Repository(pointer: GitPointer(Unwrap(pointer.get(git_reference_owner))))

        let object = try repository.object(for: target)
        switch object {
        case .tag(let annotatedTag):
            kind = .annotated(target: annotatedTag)
        default:
            kind = .lightweight(target: target)
        }
    }
}

extension Tag {

    enum Kind: Equatable, Hashable, Sendable {
        case lightweight(target: Object.ID)
        case annotated(target: AnnotatedTag)
    }
}

extension Tag {

    public var name: String {
        String(reference.rawValue.dropFirst(10)) // length of "refs/tags/"
    }

    public var target: Object.ID {
        switch kind {
        case let .annotated(tag): return tag.target
        case let .lightweight(target): return target
        }
    }
}

extension Tag: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tag(name: \(name), reference: \(reference), target: \(target.debugDescription))"
    }
}

// MARK: - Tag.ID

extension Tag {

    public struct ID: Equatable, Hashable, Sendable {
        fileprivate let name: Reference.Name
    }
}

extension Tag.ID: CustomStringConvertible {
    public var description: String { name.description }
}

// MARK: - AnnotatedTag

public struct AnnotatedTag: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public typealias ID = Tagged<AnnotatedTag, Object.ID>
    public let id: ID
    public let name: String
    public let target: Object.ID
    public let tagger: Signature
    public let message: String

    @GitActor
    init(pointer: GitPointer) throws {
        self.pointer = pointer
        id = try ID(object: pointer)
        name = try pointer.get(git_tag_name) |> String.init
        target = try pointer.get(git_tag_target_id) |> Object.ID.init
        tagger = try pointer.get(git_tag_tagger) |> Signature.init
        message = try pointer.get(git_tag_message) |> String.init
    }
}

// MARK: - Reference.tag

extension Reference {

    fileprivate var tag: Tag? {
        guard case .tag(let tag) = self else { return nil }
        return tag
    }
}

// MARK: - GitPointerInitialization

extension Tag: GitPointerInitialization {}
extension AnnotatedTag: GitPointerInitialization {}
