
struct GitIterator<Iterator, Element> {

    let iterator: Iterator
    let nextElement: (Iterator) throws -> Element?

    init(
        iterator: () throws -> Iterator,
        nextElement: @escaping (Iterator) throws -> Element?
    ) throws {
        self.iterator = try iterator()
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
