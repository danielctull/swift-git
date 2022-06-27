
import Clibgit2
import Tagged

extension Repository {

    public func tag(named name: String) throws -> Tag {
        try tags.first(where: { $0.name == name })
            ?? { throw LibGit2Error(.notFound) }()
    }

    public var tags: [Tag] {
        get throws {
            try references.compactMap(\.tag)
        }
    }
}

// MARK: - Tag

public struct Tag: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<Tag, Reference.ID>
    public let id: ID
    let kind: Kind

    init(pointer: GitPointer) throws {
        guard pointer.check(git_reference_is_tag) else { throw GitKitError.incorrectType(expected: "tag") }
        self.pointer = pointer
        id = try Tag.ID(reference: pointer)

        let target = try Object.ID(reference: pointer)
        let repository = try Repository(pointer: pointer.get(git_reference_owner))
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

    enum Kind {
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

public struct AnnotatedTag: GitReference {

    let pointer: GitPointer
    public typealias ID = Tagged<AnnotatedTag, Object.ID>
    public let id: ID
    public let name: String
    public let target: Object.ID
    public let tagger: Signature
    public let message: String

    init(pointer: GitPointer) throws {
        self.pointer = pointer
        id = try ID(object: pointer)
        name = try String(pointer.task(for: git_tag_name))
        target = try Object.ID(pointer.get(git_tag_target_id))
        tagger = try Signature(pointer.get(git_tag_tagger))
        message = try String(pointer.task(for: git_tag_message))
    }
}
