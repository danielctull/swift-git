
import Clibgit2
import Foundation

// MARK: - Signature

public struct Signature: Equatable, Hashable {
    public let name: String
    public let email: String
    public let date: Date
    public let timeZone: TimeZone
}

extension Signature {

    init(_ signature: git_signature) throws {
        name = try Unwrap(String(validatingUTF8: signature.name))
        email = try Unwrap(String(validatingUTF8: signature.email))
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
