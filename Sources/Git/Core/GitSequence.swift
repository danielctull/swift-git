
@GitActor
public struct GitSequence<Element> {
    private let nextElement: () -> Element?
}

extension GitSequence {

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
                preconditionFailure("Unexpected iterator error: \(error)")
            }
        }
    }
}

// MARK: - Sequence

extension GitSequence: Sequence, IteratorProtocol {
    public func next() -> Element? { nextElement() }
}
