
@GitActor
struct GitCollection<Index: BinaryInteger, Element> {
    let pointer: GitPointer
    let count: (OpaquePointer) -> Index
    let element: (OpaquePointer, Index) -> Element
}

extension GitCollection: RandomAccessCollection {
    public var startIndex: Index { .zero }
    public var endIndex: Index { pointer.get(count) }
    public func index(before i: Index) -> Index { i - 1 }
    public func index(after i: Index) -> Index { i + 1 }
    public subscript(position: Index) -> Element { pointer.get(element, position) }
}
