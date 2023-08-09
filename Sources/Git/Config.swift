
import Clibgit2
import Foundation

extension Repository {

    @GitActor
    public var config: Config {
        get throws {
            try Config(
                create: pointer.create(git_repository_config),
                free: git_config_free)
        }
    }
}

// MARK: - Config

public struct Config: Equatable, Hashable, Sendable {
    let pointer: GitPointer
}

extension Config {

    @GitActor
    public init(url: URL) throws {
        self = try url.withUnsafeFileSystemRepresentation { path in
            try Config(pointer: GitPointer(
                create: { git_config_open_ondisk($0, path) },
                free: git_config_free))
        }
    }

    @GitActor
    public func level(_ level: Level) throws -> Config {
        try Config(
            create: pointer.create(git_config_open_level, level.rawValue),
            free: git_config_free)
    }

    @GitActor
    public var items: GitSequence<Config.Item> {
        get throws {
            try GitSequence {

                try GitPointer(
                    create: pointer.create(git_config_iterator_new),
                    free: git_branch_iterator_free)

            } next: { iterator in

                try Item(iterator.get(git_config_next))
            }
        }
    }

    @GitActor
    public func set(_ value: String, for name: Item.Key) throws {
        try name.withCString { name in
            try value.withCString { value in
                try pointer.perform(git_config_set_string, name, value)
            }
        }
    }

    @GitActor
    public func set(_ value: Int, for name: Item.Key) throws {
        try name.withCString { name in
            try pointer.perform(git_config_set_int64, name, Int64(value))
        }
    }

    @GitActor
    public func set(_ value: Bool, for name: Item.Key) throws {
        try name.withCString { name in
            try pointer.perform(git_config_set_bool, name, Int32(value))
        }
    }
}

// MARK: - Config.Item

extension Config {

    public struct Item: Equatable, Hashable {
        public let level: Level
        public let name: Key
        public let value: Value
    }
}

extension Config.Item {

    init(_ entry: git_config_entry) {
        self.level = Config.Level(entry.level)
        self.name = entry.name |> String.init(cString:) |> Key.init
        self.value = entry.value |> String.init(cString:) |> Value.init
    }

    init(_ entry: UnsafePointer<git_config_entry>) {
        self.init(entry.pointee)
    }
}

// MARK: - Config.Item.Name

extension Config.Item {
    
    public struct Key: Equatable, Hashable, Sendable {
        private let rawValue: String

        public init(_ string: some StringProtocol) {
            rawValue = String(string)
        }
    }
}

extension Config.Item.Key: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension Config.Item.Key {

    fileprivate func withCString<Result>(
        _ body: (UnsafePointer<Int8>) throws -> Result
    ) rethrows -> Result {
        try rawValue.withCString(body)
    }
}

// MARK: - Config.Item.Value

extension Config.Item {

    public struct Value: Equatable, Hashable, Sendable {
        private let rawValue: String

        public init(_ string: some StringProtocol) {
            rawValue = String(string)
        }
    }
}

extension Config.Item.Value: ExpressibleByStringLiteral {

    public init(stringLiteral value: String) {
        self.init(value)
    }
}

// MARK: - Config.Level

extension Config {

    public struct Level: Equatable {
        fileprivate let rawValue: git_config_level_t
        fileprivate init(_ rawValue: git_config_level_t) {
            self.rawValue = rawValue
        }
    }
}

extension Config.Level: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue.rawValue)
    }
}

extension Config.Level {

    /// System-wide on Windows, for compatibility with portable git.
    public static let programData = Self(GIT_CONFIG_LEVEL_PROGRAMDATA)

    /// System-wide configuration file.
    ///
    /// `/etc/gitconfig` on Linux systems.
    public static let system = Self(GIT_CONFIG_LEVEL_SYSTEM)

    /// XDG compatible configuration file.
    ///
    /// Typically `~/.config/git/config`
    public static let xdg = Self(GIT_CONFIG_LEVEL_XDG)

    /// User-specific configuration file.
    ///
    /// Typically: `~/.gitconfig`
    ///
    /// This is also called Global configuration file.
    public static let global = Self(GIT_CONFIG_LEVEL_GLOBAL)

    /// Repository specific configuration file.
    ///
    /// `$WORK_DIR/.git/config` on non-bare repos.
    public static let local = Self(GIT_CONFIG_LEVEL_LOCAL)

    /// Application specific configuration file.
    ///
    /// Freely defined by applications.
    public static let app = Self(GIT_CONFIG_LEVEL_APP)

    /// The highest level available config file.
    ///
    /// This represents the most specific config file available that is actually
    /// loaded.
    public static let highest = Self(GIT_CONFIG_HIGHEST_LEVEL)
}

extension Config.Level: CustomStringConvertible {

    public var description: String {
        switch self {
        case .programData: "ProgramData"
        case .system: "System"
        case .xdg: "XDG"
        case .global: "Global"
        case .local: "Local"
        case .app: "App"
        case .highest: "Highest"
        default: "Unexpected config level: \(self)"
        }
    }
}

// MARK: - GitPointerInitialization

extension Config: GitPointerInitialization {}
