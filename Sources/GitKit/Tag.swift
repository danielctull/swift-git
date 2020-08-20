
import Clibgit2
import Tagged

public enum Tag {
    case lightweight(id: ID, target: Object.ID)
    case annotated(id: ID, target: AnnotatedTag)
}

// MARK: - Tag.ID

extension Tag: Identifiable {

    public typealias ID = Tagged<Tag, Reference.ID>

    public var id: ID {
        switch self {
        case let .annotated(id, _): return id
        case let .lightweight(id, _): return id
        }
    }
}

// MARK: - Properties

extension Tag {

    public var name: String {
        String(id.dropFirst(10)) // length of "refs/tags/"
    }

    public var target: Object.ID {
        switch self {
        case let .annotated(_, tag): return tag.target
        case let .lightweight(_, target): return target
        }
    }
}

// MARK: - Git Initialiser

extension Tag {

    init(_ tagReference: GitPointer) throws {
        guard tagReference.check(git_reference_is_tag) else { throw GitKitError.incorrectType(expected: "tag") }

        let id = try Tag.ID(reference: tagReference)
        let target = try Object.ID(reference: tagReference)

        let repository = try Repository(tagReference.get(git_reference_owner))
        let object = try repository.object(for: target)

        switch object {
        case .tag(let annotatedTag):
            self = .annotated(id: id, target: annotatedTag)
        default:
            self = .lightweight(id: id, target: target)
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension Tag: CustomDebugStringConvertible {
    public var debugDescription: String {
        "Tag(name: \(name), id: \(id), target: \(target.debugDescription))"
    }
}

// MARK: - AnnotatedTag

public struct AnnotatedTag {
    let tag: GitPointer
    public typealias ID = Tagged<AnnotatedTag, Object.ID>
    public let id: ID
    public let name: String
    public let target: Object.ID
    public let tagger: Signature
    public let message: String
}

extension AnnotatedTag {

    init(_ tag: GitPointer) throws {
        self.tag = tag
        id = try ID(object: tag)
        name = try Unwrap(String(validatingUTF8: tag.get(git_tag_name)))
        target = try Object.ID(tag.get(git_tag_target_id))
        tagger = try Signature(tag.get(git_tag_tagger))
        message = try Unwrap(String(validatingUTF8: tag.get(git_tag_message)))
    }
}
