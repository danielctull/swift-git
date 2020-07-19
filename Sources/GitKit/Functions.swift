
import Clibgit2

extension UInt32 {

    init(_ value: Bool) {
        switch value {
        case true: self = 1
        case false: self = 0
        }
    }
}

extension git_strarray: Sequence {

    public func makeIterator() -> AnyIterator<String> {
        var index = 0
        return AnyIterator {
            guard index < count else { return nil }
            defer { index += 1 }
            return String(validatingUTF8: strings[index]!)!
        }
    }
}
