
import Clibgit2
import Foundation

// MARK: - Signature

public struct Signature: Equatable, Hashable, Sendable {
    public let name: String
    public let email: String
    public let date: Date
    public let timeZone: TimeZone
}

extension Signature {

    init(_ signature: UnsafePointer<git_signature>) throws {
        try self.init(signature.pointee)
    }

    init(_ signature: git_signature) throws {
        name = String(cString: signature.name)
        email = String(cString: signature.email)
        date = Date(timeIntervalSince1970: TimeInterval(signature.when.time))
        timeZone = try Unwrap(TimeZone(secondsFromGMT: 60 * Int(signature.when.offset)))
    }
}

extension Signature: CustomStringConvertible {

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateStyle = .short
        formatter.timeStyle = .long
        return formatter.string(from: date)
    }

    public var description: String {
        return "Signature(name: \(name), email: \(email), date: \(formattedDate))"
    }
}
