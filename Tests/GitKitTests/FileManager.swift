
import Foundation

extension FileManager {

    func withTemporaryDirectory(_ perform: (URL) throws -> ()) throws {
        let url = temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try createDirectory(at: url, withIntermediateDirectories: true, attributes: [:])
        try perform(url)
        try removeItem(at: url)
    }
}
