//
//  EvaluationSearchEntryView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

private enum EvaluationSearchBarLayout {
    static let height: CGFloat = 38
    static let cornerRadius: CGFloat = 9
    static let background = Color(uiColor: .secondarySystemBackground)
}

private struct EvaluationSearchBarChrome<Content: View>: View {
    let foregroundColor: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .foregroundStyle(foregroundColor)
            .padding(.leading, 13)
            .padding(.trailing, 2)
            .frame(height: EvaluationSearchBarLayout.height)
            .background(EvaluationSearchBarLayout.background)
            .clipShape(RoundedRectangle(cornerRadius: EvaluationSearchBarLayout.cornerRadius, style: .continuous))
    }
}

struct EvaluationSearchEntryView: View {
    let onSearch: () -> Void
    let onFilter: () -> Void

    var body: some View {
        EvaluationSearchBarButton(
            onSearch: onSearch,
            onFilter: onFilter
        )
    }
}

struct EvaluationSearchBarButton: View {
    let onSearch: () -> Void
    let onFilter: () -> Void

    var body: some View {
        EvaluationSearchBarChrome(foregroundColor: Color(uiColor: .secondaryLabel)) {
            HStack(spacing: 0) {
                Button {
                    onSearch()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 17, weight: .regular))

                        Text("강의명, 교수명으로 검색하세요")
                            .font(.system(size: 14))
                            .lineLimit(1)

                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("강의명, 교수명으로 검색")
                .buttonStyle(.animatable())

                Button {
                    onFilter()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20, weight: .regular))
                        .frame(width: 44, height: 38)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("강의평 필터")
                .buttonStyle(.animatable())
            }
        }
    }
}

struct EvaluationSearchInputBar: View {
    @Binding var query: String
    let onBack: () -> Void
    let onFilter: () -> Void

    @FocusState private var isFocused

    var body: some View {
        EvaluationSearchBarChrome(foregroundColor: Color(uiColor: .label)) {
            HStack(spacing: 8) {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .regular))
                        .frame(width: 28, height: EvaluationSearchBarLayout.height)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("뒤로")
                .buttonStyle(.animatable())

                TextField("강의명, 교수명으로 검색하세요", text: $query)
                    .focused($isFocused)
                    .submitLabel(.search)
                    .font(.system(size: 16, weight: .medium))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .lineLimit(1)

                if !query.isEmpty {
                    Button {
                        query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(Color(uiColor: .systemGray))
                    }
                    .accessibilityLabel("검색어 지우기")
                    .buttonStyle(.animatable())
                }

                Button {
                    onFilter()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20, weight: .regular))
                        .frame(width: 32, height: EvaluationSearchBarLayout.height)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("강의평 필터")
                .buttonStyle(.animatable())
            }
        }
    }
}

struct EvaluationSearchFilterChips: View {
    let filters: [EvaluationSearchFilter]
    let onRemove: (EvaluationSearchFilter) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters) { filter in
                    Button {
                        onRemove(filter)
                    } label: {
                        SearchFilterChip(
                            title: filter.title,
                            foregroundColor: EvaluationDesignColor.mint,
                            backgroundColor: EvaluationDesignColor.mintBackground,
                            borderColor: EvaluationDesignColor.mint,
                            font: .system(size: 14, weight: .medium),
                            iconFont: .system(size: 12, weight: .regular),
                            spacing: 6,
                            horizontalPadding: 13,
                            verticalPadding: nil,
                            height: 30
                        )
                    }
                    .buttonStyle(.animatable(scale: 0.96))
                }
            }
            .padding(.horizontal, 20)
        }
        .withResponsiveTouch()
    }
}

#Preview("Search Entry") {
    EvaluationSearchEntryView(onSearch: {}, onFilter: {})
        .padding()
}

#Preview("Search Input") {
    @Previewable @State var query = "인공지능"
    EvaluationSearchInputBar(query: $query, onBack: {}, onFilter: {})
        .padding()
}

#Preview("Filter Sheet") {
    @Previewable @State var filters = EvaluationSearchFilter.previewSelected
    Color.gray.opacity(0.4)
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            EvaluationSearchFilterSheet(selectedFilters: $filters)
        }
}
