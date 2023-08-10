
@GitActor
public struct GitIterator<Element> {
    private let nextElement: () -> Element?
}

extension GitIterator {

    init<Iterator>(
        iterator: @GitActor () throws -> Iterator,
        next: @escaping @GitActor (Iterator) throws -> Element
    ) throws {
        let iterator = try iterator()
        nextElement = {
            do {
                return try next(iterator)
            } catch let error as GitError where error.code == .iteratorOver {
                return nil
            } catch {
                fatalError("Iterator error: \(error)")
            }
        }
    }
}

// MARK: - Sequence

extension GitIterator: IteratorProtocol, Sequence {
    public func next() -> Element? { nextElement() }
}
