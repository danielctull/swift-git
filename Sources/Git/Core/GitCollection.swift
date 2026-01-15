public struct GitCollection<Element, Index: BinaryInteger> {
  let count: () -> Index
  let element: (Index) -> Element
}

// MARK: - Collection

extension GitCollection: RandomAccessCollection {
  public var startIndex: Index { 0 }
  public var endIndex: Index { count() }
  public func index(after i: Index) -> Index { i + 1 }
  public func index(before i: Index) -> Index { i - 1 }
  public subscript(position: Index) -> Element { element(position) }
}
