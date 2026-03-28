//
//  ActionSheetBuilder.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

@resultBuilder
public enum ActionSheetBuilder {
    public static func buildExpression(_ item: ActionSheetItem) -> [ActionSheetItem] {
        [item]
    }

    public static func buildBlock(_ items: [ActionSheetItem]...) -> [ActionSheetItem] {
        items.flatMap { $0 }
    }

    public static func buildOptional(_ items: [ActionSheetItem]?) -> [ActionSheetItem] {
        items ?? []
    }

    public static func buildEither(first items: [ActionSheetItem]) -> [ActionSheetItem] {
        items
    }

    public static func buildEither(second items: [ActionSheetItem]) -> [ActionSheetItem] {
        items
    }
}
