
import Clibgit2
// import Foundation
import Tagged

extension Repository {

    public func remote(for id: Remote.ID) throws -> Remote {
        let remote = try GitPointer(
            create: repository.create(git_remote_lookup, id.rawValue),
            free: git_remote_free)
        return try Remote(remote)
    }
}

// MARK: Remote

public struct Remote: Identifiable {
    let remote: GitPointer
    public typealias ID = Tagged<Remote, String>
    public let id: ID
//    public let url: URL
}

extension Remote {
    public var name: String { id.rawValue }
}

extension Remote {

    init(_ remote: GitPointer) throws {
        self.remote = remote
        id = try ID(remote.get(git_remote_name))
//        let urlString = try Unwrap(String(remote.get(git_remote_url)))
//        url = try Unwrap(URL(string: urlString))
    }
}
