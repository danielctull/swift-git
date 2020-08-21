
import Clibgit2

extension Repository {

    public func object(for id: Object.ID) throws -> Object {
        var oid = id.oid
        let pointer = try GitPointer(
            create: { git_object_lookup($0, repository.pointer, &oid, GIT_OBJECT_ANY) },
            free: git_object_free)
        return try Object(pointer)
    }
}
