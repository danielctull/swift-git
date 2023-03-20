
import Clibgit2
// import Foundation
import Tagged

extension Repository {

    @GitActor
    public func remote(for id: Remote.ID) throws -> Remote {
        try Remote(
            create: pointer.get(git_remote_lookup, id.rawValue),
            free: git_remote_free)
    }
}

// MARK: Remote

public struct Remote: GitReference, Identifiable {

    let pointer: GitPointer
    public typealias ID = Tagged<Remote, String>
    public let id: ID
//    public let url: URL

    init(pointer: GitPointer) throws {
        self.pointer = pointer
        let name = try pointer.get(git_remote_name) |> String.init
        id = ID(name)

//        let urlString = try Unwrap(String(remote.get(git_remote_url)))
//        url = try Unwrap(URL(string: urlString))
    }
}

extension Remote {
    public var name: String { id.rawValue }
}
