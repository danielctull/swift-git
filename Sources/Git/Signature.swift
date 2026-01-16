import libgit2
import Foundation

extension Repository {

  public var defaultSignature: Signature {
    get throws {
      try Signature(pointer.get(git_signature_default) |> Unwrap)
    }
  }
}

// MARK: - Signature

public struct Signature: Equatable, Hashable, Sendable {
  public let name: String
  public let email: String
  public let date: Date
  public let timeZone: TimeZone

  public init(
    name: String,
    email: String,
    date: Date = .now,
    timeZone: TimeZone = .autoupdatingCurrent
  ) {

    let time = git_time(
      time: git_time_t(date.timeIntervalSince1970),
      offset: Int32(timeZone.secondsFromGMT() / 60),
      sign: 0)

    self = name.withMutableCString { name in
      email.withMutableCString { email in
        Signature(git_signature(name: name, email: email, when: time))
      }
    }
  }
}

extension Signature {

  init(_ signature: UnsafePointer<git_signature>) {
    self.init(signature.pointee)
  }

  init(_ signature: git_signature) {
    name = String(cString: signature.name)
    email = String(cString: signature.email)
    date = Date(timeIntervalSince1970: TimeInterval(signature.when.time))
    timeZone = TimeZone(secondsFromGMT: 60 * Int(signature.when.offset))!
  }
}

extension Signature {

  func withUnsafePointer<Result>(
    _ body: (UnsafePointer<git_signature>) throws -> Result
  ) rethrows -> Result {
    try name.withMutableCString { name in
      try email.withMutableCString { email in

        let time = git_time(
          time: git_time_t(date.timeIntervalSince1970),
          offset: Int32(timeZone.secondsFromGMT() / 60),
          sign: 0)
        let signature = git_signature(name: name, email: email, when: time)
        return try Swift.withUnsafePointer(to: signature, body)
      }
    }
  }
}

extension String {

  fileprivate func withMutableCString<Result>(
    _ body: (UnsafeMutablePointer<Int8>) throws -> Result
  ) rethrows -> Result {
    try withCString { string in
      try body(UnsafeMutablePointer(mutating: string))
    }
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
