
struct GitIterator<Element> {

    let iterator: GitPointer
    let nextElement: (GitPointer) throws -> Element?

    init(
        createIterator: @autoclosure () throws -> OpaquePointer,
        configureIterator: ((GitPointer) throws -> Void)? = nil,
        freeIterator: @escaping GitPointer.Free,
        nextElement: @escaping (GitPointer) throws -> Element?
    ) throws {
        iterator = try GitPointer(create: createIterator(), free: freeIterator)
        try configureIterator?(iterator)
        self.nextElement = nextElement
    }
}

extension GitIterator: IteratorProtocol, Sequence {

    mutating func next() -> Element? {
        do {
            return try nextElement(iterator)
        } catch let error as GitError where error.code == .iteratorOver {
            return nil
        } catch {
            fatalError("Iterator error: \(error)")
        }
    }
}
