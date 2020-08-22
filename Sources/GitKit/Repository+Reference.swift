
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

    public func remove(_ reference: Reference) throws {
        try remove(reference.id)
    }

    public func remove(_ id: Reference.ID) throws {
        let result = git_reference_remove(repository.pointer, id.rawValue)
        if let error = LibGit2Error(result) { throw error }
    }
}
