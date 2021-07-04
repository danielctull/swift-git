
import Cgit2

extension Repository {

    public func tag(named name: String) throws -> Tag {
        try tags().first(where: { $0.name == name })
            ?? { throw LibGit2Error(.notFound) }()
    }

    public func tags() throws -> [Tag] {
        try references()
            .compactMap(\.tag)
    }
}
