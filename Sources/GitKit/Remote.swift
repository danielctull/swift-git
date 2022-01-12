
import Clibgit2
// import Foundation
import Tagged

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

    init(_ remote: GitPointer) async throws {
        self.remote = remote
        id = try await ID(remote.get(git_remote_name))
//        let urlString = try Unwrap(String(remote.get(git_remote_url)))
//        url = try Unwrap(URL(string: urlString))
    }
}
