
import Clibgit2

public struct ObjectID {
    let oid: git_oid

    init(_ oid: git_oid) {
        self.oid = oid
    }
}

extension ObjectID {

    init(reference: GitPointer) throws {
        let resolved = try GitPointer(create: { git_reference_resolve($0, reference.pointer) },
                                      free: git_reference_free)
        try self.init(resolved.get(git_reference_target))
    }
}

extension ObjectID: CustomStringConvertible {
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

extension ObjectID: CustomDebugStringConvertible {

    public var debugDescription: String {
        String(description.dropLast(33))
    }
}

extension ObjectID: Equatable {

    public static func == (lhs: ObjectID, rhs: ObjectID) -> Bool {
        withUnsafePointer(to: lhs.oid) { lhs in
            withUnsafePointer(to: rhs.oid) { rhs in
                git_oid_cmp(lhs, rhs) == 0
            }
        }
    }
}

extension ObjectID: Hashable {

    public func hash(into hasher: inout Hasher) {
        withUnsafeBytes(of: oid.id) {
            hasher.combine(bytes: $0)
        }
    }
}
