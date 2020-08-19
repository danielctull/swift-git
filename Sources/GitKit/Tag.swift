
import Clibgit2
import Tagged

public enum Tag: Equatable, Identifiable {
    public typealias ID = Tagged<Tag, Reference.ID>
    case lightweight(LightweightTag)
    case annotated(AnnotatedTag)
}

extension Tag {

    public var id: ID {
        switch self {
        case let .annotated(tag): return tag.id
        case let .lightweight(tag): return tag.id
        }
    }


    public var name: String {
        String(id.dropFirst(10)) // length of "refs/tags/"
    }

    public var target: Object.ID {
        switch self {
        case let .annotated(tag): return tag.target
        case let .lightweight(tag): return tag.target
        }
    }
}

extension Tag {

    init(_ tagReference: GitPointer) throws {
        guard tagReference.check(git_reference_is_tag) else { throw GitKitError.incorrectType(expected: "tag") }
        let repo = try Unwrap(tagReference.get(git_reference_owner))
        var oid = try Unwrap(tagReference.get(git_reference_target)).pointee

        let id = try Tag.ID(rawValue: Reference.ID(reference: tagReference))
        let objectID = Object.ID(oid)
        let tagObject = try? GitPointer(create: { git_object_lookup($0, repo, &oid, GIT_OBJECT_TAG) },
                                        free: git_object_free)

        switch tagObject {
        case .none:
            self = .lightweight(LightweightTag(id: id, target: objectID))
        case .some(let tagObject):
            self = try .annotated(AnnotatedTag(id: id, tag: tagObject))
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

public struct AnnotatedTag: Equatable {
    public let id: Tag.ID
    public let objectID: Object.ID
    public let target: Object.ID
    public let tagger: Signature
    public let message: String
}

extension AnnotatedTag {

    fileprivate init(id: Tag.ID, tag: GitPointer) throws {
        self.id = id
        objectID = try Object.ID(tag.get(git_tag_id))
        target = try Object.ID(tag.get(git_tag_target_id))
        tagger = try Signature(tag.get(git_tag_tagger))
        message = try Unwrap(String(validatingUTF8: tag.get(git_tag_message)))
    }
}

// MARK: - LightweightTag

public struct LightweightTag: Equatable {
    public let id: Tag.ID
    public let target: Object.ID
}
