
struct GitIterator<Element> {

    let iterator: GitPointer
    let nextElement: (GitPointer) throws -> Element?

    init(
        createIterator: GitPointer.Create,
        configureIterator: GitPointer.Configure? = nil,
        freeIterator: @escaping GitPointer.Free,
        nextElement: @escaping (GitPointer) throws -> Element?
    ) throws {
        iterator = try GitPointer(create: createIterator, configure: configureIterator, free: freeIterator)
        self.nextElement = nextElement
    }
}

extension GitIterator: IteratorProtocol, Sequence {

    mutating func next() -> Element? {
        do {
            return try nextElement(iterator)
        } catch let error as LibGit2Error where error.code == .iteratorOver {
            return nil
        } catch {
            fatalError("Iterator error: \(error)")
        }
    }
}

extension GitIterator where Element == GitPointer {

    init(
        createIterator: GitPointer.Create,
        configureIterator: GitPointer.Configure? = nil,
        freeIterator: @escaping GitPointer.Free,
        nextElement: @escaping (UnsafeMutablePointer<OpaquePointer?>, OpaquePointer) -> Int32,
        configureElement: GitPointer.Configure? = nil,
        freeElement: @escaping GitPointer.Free
    ) throws {

        try self.init(
            createIterator: createIterator,
            configureIterator: configureIterator,
            freeIterator: freeIterator,
            nextElement: { iterator in
                try GitPointer(create: iterator.task(nextElement),
                               configure: configureElement,
                               free: freeElement)
            })
    }
}
