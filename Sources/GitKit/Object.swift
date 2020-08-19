
import Clibgit2
import Tagged

public enum Object {
    case blob(Blob)
    case commit(Commit)
    case tag(AnnotatedTag)
    case tree(Tree)
}

extension Object: Identifiable {

    public struct ID {
        let oid: git_oid
    }

    public var id: ID {
        switch self {
        case let .blob(blob): return blob.id.rawValue
        case let .commit(commit): return commit.id.rawValue
        case let .tag(tag): return tag.id.rawValue
        case let .tree(tree): return tree.id.rawValue
        }
    }
}

extension Object.ID {

    init(_ oid: git_oid) {
        self.oid = oid
    }

    init(reference: GitPointer) throws {
        let resolved = try GitPointer(create: { git_reference_resolve($0, reference.pointer) },
                                      free: git_reference_free)
        try self.init(resolved.get(git_reference_target))
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
        let objectID = try Object.ID(object.get(git_object_id))
        self.init(rawValue: objectID)
    }
}
