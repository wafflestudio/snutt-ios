//
//  TwoColumnFilterPicker.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility

/// A two-column filter picker: categories on the leading side, the selected category's options on the trailing side.
///
/// The trailing column is a plain `List`, so `detail` should return rows, typically ``FilterOptionRow``s.
public struct TwoColumnFilterPicker<Category: Identifiable, Detail: View>: View {
    private let categories: [Category]
    private let selectedCategory: Category?
    private let title: (Category) -> String
    private let selectedCount: (Category) -> Int
    private let accentColor: Color
    private let onSelectCategory: (Category) -> Void
    private let detail: (Category) -> Detail

    public init(
        categories: [Category],
        selectedCategory: Category?,
        title: @escaping (Category) -> String,
        selectedCount: @escaping (Category) -> Int,
        accentColor: Color,
        onSelectCategory: @escaping (Category) -> Void,
        @ViewBuilder detail: @escaping (Category) -> Detail
    ) {
        self.categories = categories
        self.selectedCategory = selectedCategory
        self.title = title
        self.selectedCount = selectedCount
        self.accentColor = accentColor
        self.onSelectCategory = onSelectCategory
        self.detail = detail
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 0) {
            FilterCategoryColumn(
                categories: categories,
                selectedCategoryID: selectedCategory?.id,
                title: title,
                selectedCount: selectedCount,
                accentColor: accentColor,
                onSelect: onSelectCategory
            )

            Divider()
                .ignoresSafeArea(edges: .bottom)

            List {
                if let selectedCategory {
                    Group {
                        detail(selectedCategory)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .softTopScrollEdge()
            .id(selectedCategory?.id)
        }
        .animation(.defaultSpring, value: selectedCategory?.id)
    }
}

private struct FilterCategoryColumn<Category: Identifiable>: View {
    let categories: [Category]
    let selectedCategoryID: Category.ID?
    let title: (Category) -> String
    let selectedCount: (Category) -> Int
    let accentColor: Color
    let onSelect: (Category) -> Void

    /// The narrowest the column gets; it widens to fit the longest title on one line.
    @ScaledMetric private var minColumnWidth = 112.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(categories) { category in
                    let isSelected = category.id == selectedCategoryID
                    let count = selectedCount(category)
                    Button {
                        onSelect(category)
                    } label: {
                        HStack(spacing: 6) {
                            // Sized by the semibold title, so the longest title turning bold doesn't widen the column.
                            Text(title(category))
                                .font(.callout.weight(.semibold))
                                .lineLimit(1)
                                .hidden()
                                .overlay(alignment: .leading) {
                                    Text(title(category))
                                        .font(.callout.weight(isSelected ? .semibold : .regular))
                                        .foregroundStyle(
                                            isSelected ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary)
                                        )
                                        .fixedSize()
                                        // Animating the weight drops the Hangul glyphs of mixed titles such as
                                        // "구) 교양영역" for a few frames, leaving only ")". Swap it instantly.
                                        .contentTransition(.identity)
                                }
                            // Reserves the badge's width even when it is hidden, so selecting doesn't widen the column.
                            ZStack {
                                if count > 0 {
                                    Text(count, format: .number)
                                        .font(.caption2.weight(.bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 6)
                                        .frame(minWidth: 18, minHeight: 18)
                                        .background(accentColor, in: .capsule)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .frame(minWidth: 18)
                        }
                        .padding(.horizontal, 12)
                        .frame(minWidth: minColumnWidth - 16, maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 44)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemFill))
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.animatable(scale: 0.97))
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityValue(count > 0 ? SharedUIComponentsStrings.filterSelectedCount(count) : "")
                }
            }
            // Sizes every row to the widest one, so the selection backgrounds line up.
            .fixedSize(horizontal: true, vertical: false)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .fixedSize(horizontal: true, vertical: false)
        .scrollIndicators(.hidden)
        .softTopScrollEdge()
    }
}

/// A checkable option row for ``TwoColumnFilterPicker``.
public struct FilterOptionRow: View {
    private let title: String
    private let isSelected: Bool
    private let accentColor: Color
    private let onToggle: () -> Void

    public init(title: String, isSelected: Bool, accentColor: Color, onToggle: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.accentColor = accentColor
        self.onToggle = onToggle
    }

    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? accentColor : Color(uiColor: .systemGray3))
                    .contentTransition(.symbolEffect(.replace))
                Text(title)
                    .font(.callout)
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

extension View {
    /// Both columns scroll on their own, and the automatic style draws each one as a hard edge on iOS 27.
    @ViewBuilder
    fileprivate func softTopScrollEdge() -> some View {
        if #available(iOS 26, *) {
            scrollEdgeEffectStyle(.soft, for: .top)
        } else {
            self
        }
    }
}

private struct PreviewCategory: Identifiable {
    let id: Int
    let name: String
    let options: [String]
}

#Preview {
    @Previewable @State var selectedCategoryID = 0
    @Previewable @State var selectedOptions: Set<String> = ["3학점"]
    let categories = [
        PreviewCategory(id: 0, name: "학점", options: ["1학점", "2학점", "3학점", "4학점"]),
        PreviewCategory(id: 1, name: "학년", options: ["1학년", "2학년", "3학년", "4학년"]),
    ]
    TwoColumnFilterPicker(
        categories: categories,
        selectedCategory: categories.first { $0.id == selectedCategoryID },
        title: \.name,
        selectedCount: { $0.options.count(where: selectedOptions.contains) },
        accentColor: .teal,
        onSelectCategory: { selectedCategoryID = $0.id },
        detail: { category in
            ForEach(category.options, id: \.self) { option in
                FilterOptionRow(title: option, isSelected: selectedOptions.contains(option), accentColor: .teal) {
                    withAnimation(.defaultSpring) {
                        if selectedOptions.contains(option) {
                            selectedOptions.remove(option)
                        } else {
                            selectedOptions.insert(option)
                        }
                    }
                }
            }
        }
    )
}
