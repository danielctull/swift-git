
import Clibgit2

extension Repository {

    public func tags() throws -> [Tag] {
        try references()
            .compactMap(\.tag)
    }
}
