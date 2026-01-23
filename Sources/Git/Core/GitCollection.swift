struct GitCollection<Element, Index: BinaryInteger> {
  let count: () -> Index
  let element: (Index) -> Element
}

// MARK: - Collection

extension GitCollection: RandomAccessCollection {
  var startIndex: Index { 0 }
  var endIndex: Index { count() }
  func index(after i: Index) -> Index { i + 1 }
  func index(before i: Index) -> Index { i - 1 }
  subscript(position: Index) -> Element { element(position) }
}
