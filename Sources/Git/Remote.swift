
import Clibgit2

extension Repository {

    @GitActor
    public func remote(named name: Remote.Name) throws -> Remote {
        try name.withCString { name in
            try Remote(
                create: pointer.create(git_remote_lookup, name),
                free: git_remote_free)
        }
    }
}

// MARK: Remote

public struct Remote: Equatable, Hashable, Identifiable, Sendable {

    let pointer: GitPointer
    public let id: ID
    public let name: Name
//    public let url: URL

    @GitActor
    init(pointer: GitPointer) throws {
        self.pointer = pointer
        name = try Name(pointer.get(git_remote_name) |> Unwrap |> String.init(cString:))
        id = ID(name: name)

//        let urlString = try Unwrap(String(remote.get(git_remote_url)))
//        url = try Unwrap(URL(string: urlString))
    }
}

// MARK: - Remote.ID

extension Remote {

    public struct ID: Equatable, Hashable, Sendable {
        let name: Name
    }
}

// MARK: - Remote.Name

extension Remote {

    public struct Name: Equatable, Hashable, Sendable {
        private let rawValue: String

        public init(_ value: some StringProtocol) {
            rawValue = String(value)
        }
    }
}

extension Remote.Name: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Remote.Name: CustomStringConvertible {

    public var description: String { rawValue }
}

extension Remote.Name {

    fileprivate func withCString<Result>(
        _ body: (UnsafePointer<Int8>) throws -> Result
    ) rethrows -> Result {
        try rawValue.withCString(body)
    }
}

// MARK: - GitPointerInitialization

extension Remote: GitPointerInitialization {}
