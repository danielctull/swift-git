
@GitActor
struct GitCollection<Index: BinaryInteger, Element> {
    let count: () -> Index
    let element: (Index) -> Element
}

extension GitCollection: RandomAccessCollection {
    public var startIndex: Index { .zero }
    public var endIndex: Index { count() }
    public func index(before i: Index) -> Index { i - 1 }
    public func index(after i: Index) -> Index { i + 1 }
    public subscript(position: Index) -> Element { element(position) }
}

extension GitCollection {

    init(
        pointer: GitPointer,
        count: @escaping (OpaquePointer) -> Index,
        element: @escaping (OpaquePointer, Index) -> Element
    ) {
        self.count = { pointer.get(count) }
        self.element = { index in pointer.get(element, index) }
    }
}
