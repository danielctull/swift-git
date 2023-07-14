
import Clibgit2
// import Foundation
import Tagged

extension Repository {

    @GitActor
    public func remote(named name: Remote.Name) throws -> Remote {
        try name.rawValue.withCString { id in
            try Remote(
                create: pointer.create(git_remote_lookup, id),
                free: git_remote_free)
        }
    }
}

// MARK: Remote

public struct Remote: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public typealias ID = Tagged<Remote, String>
    public let id: ID
    public let name: Name
//    public let url: URL

    @GitActor
    init(pointer: GitPointer) throws {
        self.pointer = pointer
        let name = try pointer.get(git_remote_name) |> String.init
        id = ID(name)
        self.name = Name(rawValue: name)

//        let urlString = try Unwrap(String(remote.get(git_remote_url)))
//        url = try Unwrap(URL(string: urlString))
    }
}

// MARK: - Remote.Name

extension Remote {

    public struct Name: Equatable, Hashable, Sendable {
        let rawValue: String
    }
}

extension Remote.Name: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

extension Remote.Name: CustomStringConvertible {

    public var description: String { rawValue }
}

// MARK: - GitPointerInitialization

extension Remote: GitPointerInitialization {}
