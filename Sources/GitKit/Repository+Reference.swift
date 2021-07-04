
import Clibgit2

extension Repository {

    public func head() throws -> Reference {
        let head = try GitPointer(create: { git_repository_head($0, repository.pointer) },
                                  free: git_reference_free)
        return try Reference(head)
    }

    public func references() throws -> [Reference] {

        try GitIterator(
            createIterator: { git_reference_iterator_new($0, repository.pointer) },
            freeIterator: git_reference_iterator_free,
            nextElement: git_reference_next,
            freeElement: git_reference_free)
            .map(Reference.init)
    }

    public func reference(for id: Reference.ID) throws -> Reference {
        let pointer = try GitPointer(
            create: { git_reference_lookup($0, repository.pointer, id.rawValue) },
            free: git_reference_free)
        return try Reference(pointer)
    }
}

// MARK: - Removing References

extension Repository {

    @available(iOS 13, *)
    @available(macOS 10.15, *)
    public func remove<SomeReference>(
        _ reference: SomeReference
    ) throws where SomeReference: Identifiable,
                   SomeReference.ID: RawRepresentable,
                   SomeReference.ID.RawValue == Reference.ID {
        try remove(reference.id.rawValue)
    }

    public func remove<ID>(
        _ id: ID
    ) throws where ID: RawRepresentable, ID.RawValue == Reference.ID {
        try remove(id.rawValue)
    }

    public func remove(_ id: Reference.ID) throws {
        try remove(reference(for: id))
    }

    public func remove(_ reference: Reference) throws {
        let result = git_reference_remove(repository.pointer, reference.id.rawValue)
        if let error = LibGit2Error(result) { throw error }
    }
}
