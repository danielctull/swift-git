
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

extension GitIterator where Element == GitPointer {

    init(
        createIterator: @autoclosure () throws -> OpaquePointer,
        configureIterator: ((GitPointer) throws -> Void)? = nil,
        freeIterator: @escaping GitPointer.Free,
        nextElement: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32,
        freeElement: @escaping GitPointer.Free
    ) throws {

        try self.init(
            createIterator: createIterator(),
            configureIterator: configureIterator,
            freeIterator: freeIterator,
            nextElement: { iterator in
                try GitPointer(create: iterator.get(nextElement),
                               free: freeElement)
            })
    }
}
