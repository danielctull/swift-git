
import Clibgit2

extension Repository {

    public func object<ID>(
        for id: ID
    ) async throws -> Object where ID: RawRepresentable, ID.RawValue == Object.ID {
        try await object(for: id.rawValue)
    }

    public func object(for id: Object.ID) async throws -> Object {
        var oid = id.oid
        let pointer = try await GitPointer(
            create: repository.create(git_object_lookup, &oid, GIT_OBJECT_ANY),
            free: git_object_free)
        return try await Object(pointer)
    }
}
