
struct GitIterator<Element> {

    let iterator: GitPointer
    let nextElement: (OpaquePointer) throws -> Element?

    init(
        create: (UnsafeMutablePointer<OpaquePointer?>) -> Int32,
        free: @escaping (OpaquePointer) -> Void,
        next: @escaping (OpaquePointer) throws -> Element?
    ) throws {
        iterator = try GitPointer(create: create, free: free)
        nextElement = next
    }
}

extension GitIterator: IteratorProtocol {

    mutating func next() -> Element? {
        do {
            return try nextElement(iterator.pointer)
        } catch let error as GitError where error == GitError(.iteratorOver) {
            return nil
        } catch {
            print("Iterator error", error)
            return nil
        }
    }
}
