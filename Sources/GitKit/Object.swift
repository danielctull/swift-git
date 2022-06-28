
import Clibgit2
import Tagged

extension Repository {

    public func object<ID>(
        for id: ID
    ) throws -> Object where ID: RawRepresentable, ID.RawValue == Object.ID {
        try object(for: id.rawValue)
    }

    public func object(for id: Object.ID) throws -> Object {
        var oid = id.oid
        return try Object(
            create: task(for: git_object_lookup, &oid, GIT_OBJECT_ANY),
            free: git_object_free)
    }
}

// MARK: - Object

public enum Object {
    case blob(Blob)
    case commit(Commit)
    case tag(AnnotatedTag)
    case tree(Tree)
}

extension Object: GitReference {

    var pointer: GitPointer {
        switch self {
        case .blob(let blob): return blob.pointer
        case .commit(let commit): return commit.pointer
        case .tag(let annotatedTag): return annotatedTag.pointer
        case .tree(let tree): return tree.pointer
        }
    }

    init(pointer: GitPointer) throws {

        let type = try pointer
            .task(for: git_object_type)()

        switch type {

        case GIT_OBJECT_BLOB:
            self = try .blob(Blob(pointer: pointer))

        case GIT_OBJECT_COMMIT:
            self = try .commit(Commit(pointer: pointer))

        case GIT_OBJECT_TAG:
            self = try .tag(AnnotatedTag(pointer: pointer))

        case GIT_OBJECT_TREE:
            self = try .tree(Tree(pointer: pointer))

        default:
            let typeName = try Unwrap(String(validatingUTF8: git_object_type2string(type)))
            let expected = try [GIT_OBJECT_BLOB, GIT_OBJECT_COMMIT, GIT_OBJECT_TAG, GIT_OBJECT_TREE]
                .map { try Unwrap(String(validatingUTF8: git_object_type2string($0))) }
            throw GitKitError.unexpectedValue(expected: expected, received: typeName)
        }
    }
}

extension Object: Identifiable {

    public var id: ID {
        switch self {
        case let .blob(blob): return blob.id.rawValue
        case let .commit(commit): return commit.id.rawValue
        case let .tag(tag): return tag.id.rawValue
        case let .tree(tree): return tree.id.rawValue
        }
    }
}

// MARK: - Object.ID

extension Object {

    public struct ID {
        let oid: git_oid
    }
}

extension Object.ID {

    init(reference: GitPointer) throws {
        let resolved = try GitPointer(
            create: reference.task(for: git_reference_resolve),
            free: git_reference_free)

        self = try resolved
            .task(for: git_reference_target)
            .map(Unwrap)
            .map(\.pointee)
            .map(Self.init)()
    }
}

extension Object.ID: CustomStringConvertible {

    public var description: String {
        withUnsafePointer(to: oid) { oid in
            let length = Int(GIT_OID_RAWSZ) * 2
            let string = UnsafeMutablePointer<Int8>.allocate(capacity: length)
            git_oid_fmt(string, oid)
            // swiftlint:disable force_unwrapping
            return String(bytesNoCopy: string, length: length, encoding: .ascii, freeWhenDone: true)!
            // swiftlint:enable force_unwrapping
        }
    }
}

extension Object.ID: CustomDebugStringConvertible {

    public var debugDescription: String {
        String(description.dropLast(33))
    }
}

extension Object.ID: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        withUnsafePointer(to: lhs.oid) { lhs in
            withUnsafePointer(to: rhs.oid) { rhs in
                git_oid_cmp(lhs, rhs) == 0
            }
        }
    }
}

extension Object.ID: Hashable {

    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: oid.id) {
            hasher.combine(bytes: $0)
        }
    }
}

// MARK: - Tagged + Object.ID

extension Tagged where RawValue == Object.ID {

    init(object: GitPointer) throws {
        self = try object
            .task(for: git_object_id)
            .map(Unwrap)
            .map(\.pointee)
            .map(Self.init)()
    }

    init(oid: git_oid) {
        let objectID = Object.ID(oid: oid)
        self.init(rawValue: objectID)
    }
}
