//
//  CursorPage.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

/// A page of items returned by a cursor-paginated endpoint.
struct CursorPage<Item: Sendable & Equatable>: Equatable, Sendable {
    let items: [Item]
    /// The cursor for the next page, or `nil` when this is the last page.
    let nextCursor: String?
}

/// Items accumulated across cursor-paginated requests.
struct PagedContent<Item: Identifiable & Sendable & Equatable>: Equatable, Sendable where Item.ID: Sendable {
    private(set) var items: [Item]
    private(set) var nextCursor: String?

    init(items: [Item] = [], nextCursor: String? = nil) {
        self.items = items
        self.nextCursor = nextCursor
    }

    init(_ page: CursorPage<Item>) {
        self.init(items: page.items, nextCursor: page.nextCursor)
    }

    var canLoadMore: Bool { nextCursor != nil }

    func appending(_ page: CursorPage<Item>) -> PagedContent {
        var seenIDs = Set(items.map(\.id))
        let newItems = page.items.filter { seenIDs.insert($0.id).inserted }
        return PagedContent(items: items + newItems, nextCursor: page.nextCursor)
    }

    mutating func update(_ id: Item.ID, _ transform: (inout Item) -> Void) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        transform(&items[index])
    }

    mutating func remove(_ id: Item.ID) {
        items.removeAll { $0.id == id }
    }
}
