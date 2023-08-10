
@GitActor
public struct GitCollection<Element> {
    private let count: () -> Int
    private let element: (Int) -> Element
}

extension GitCollection {

    init<I: BinaryInteger>(
        count: @escaping @GitActor () -> I,
        element: @escaping @GitActor (I) -> Element
    ) {
        self.count = { Int(count()) }
        self.element = { element(I($0)) }
    }
}

// MARK: - Collection

extension GitCollection: RandomAccessCollection {

    public struct Index: Comparable {
        fileprivate let value: Int
        public static func < (lhs: Self, rhs: Self) -> Bool { 
            lhs.value < rhs.value
        }
    }

    public var startIndex: Index { Index(value: 0) }
    public var endIndex: Index { Index(value: count()) }
    public func index(after i: Index) -> Index { Index(value: i.value + 1) }
    public func index(before i: Index) -> Index { Index(value: i.value - 1) }
    public subscript(position: Index) -> Element { element(position.value) }
}
