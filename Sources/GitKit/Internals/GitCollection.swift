
struct GitCollection<Element> {
    let pointer: GitPointer
    let count: (OpaquePointer) -> Int
    let element: (OpaquePointer, Int) -> Element
}

extension GitCollection: RandomAccessCollection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count(pointer.pointer) }
    public subscript(position: Int) -> Element { element(pointer.pointer, position) }
}
