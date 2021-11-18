
import Clibgit2

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
