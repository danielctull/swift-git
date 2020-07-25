
struct GitIterator<Element> {

    let iterator: GitPointer
    let nextElement: (OpaquePointer) throws -> Element?

    init(
        createIterator: (UnsafeMutablePointer<OpaquePointer?>) -> Int32,
        configureIterator: ((OpaquePointer) -> Int32)? = nil,
        freeIterator: @escaping (OpaquePointer) -> Void,
        nextElement: @escaping (OpaquePointer) throws -> Element?
    ) throws {
        iterator = try GitPointer(create: createIterator, configure: configureIterator, free: freeIterator)
        self.nextElement = nextElement
    }
}

extension GitIterator: IteratorProtocol, Sequence {

    mutating func next() -> Element? {
        do {
            return try nextElement(iterator.pointer)
        } catch let error as LibGit2Error where error.code == .iteratorOver {
            return nil
        } catch {
            fatalError("Iterator error: \(error)")
        }
    }
}

extension GitIterator where Element == GitPointer {

    init(
        createIterator: (UnsafeMutablePointer<OpaquePointer?>) -> Int32,
        configureIterator: ((OpaquePointer) -> Int32)? = nil,
        freeIterator: @escaping (OpaquePointer) -> Void,
        nextElement: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32,
        freeElement: @escaping (OpaquePointer) -> Void
    ) throws {

        try self.init(
            createIterator: createIterator,
            configureIterator: configureIterator,
            freeIterator: freeIterator,
            nextElement: { iterator in
                try GitPointer(create: { nextElement($0, iterator) },
                               free: freeElement)
            })
    }
}
