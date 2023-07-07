
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
    public typealias ID = Tagged<Tag, Reference.ID>
    public let id: ID
    let kind: Kind

    @GitActor
    init(pointer: GitPointer) throws {
        pointer.assert(git_reference_is_tag, "Expected tag.")
        self.pointer = pointer
        id = try Tag.ID(reference: pointer)

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
        String(id.dropFirst(10)) // length of "refs/tags/"
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
        "Tag(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
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

// MARK: - GitPointerInitialization

extension Tag: GitPointerInitialization {}
extension AnnotatedTag: GitPointerInitialization {}
