//
//  SearchFilterSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents
import SwiftUIIntrospect
import FoundationUtility

struct SearchFilterSheet: View {
    @Bindable var viewModel: LectureSearchViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                filterToolbar
                HStack(alignment: .top) {
                    filterCategoryColumn
                        .frame(width: 150)
                    Divider()
                    filterSelectionColumn
                }
                .padding(.horizontal, 5)
                Spacer()
                filterApplyButton
            }
        }
        .presentationDetents([.height(450)])
        .presentationCornerRadius(15)
    }

    private var filterToolbar: some View {
        HStack {
            Spacer()
            ToolbarButton(image: TimetableAsset.xmark.image, contentInsets: .all(10)) {
                dismiss()
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 10)
    }

    private var filterCategoryColumn: some View {
        VStack {
            ForEach(SearchFilterCategory.supportedCases, id: \.rawValue) { category in
                let isSelected = viewModel.selectedCategory == category
                AnimatableButton(
                    animationOptions: .backgroundColor(touchDown: .label.opacity(0.05)).scale(0.95),
                    layoutOptions: [.expandHorizontally, .respectIntrinsicHeight]
                ) {
                    viewModel.selectedCategory = category
                } configuration: { button in
                    var config = UIButton.Configuration.plain()
                    config.title = category.localizedDescription
                    config.attributedTitle = .init(category.localizedDescription, attributes: .init([.font: UIFont.systemFont(ofSize: 18, weight: .semibold)]))
                    config.baseForegroundColor = isSelected ? .label : .label.withAlphaComponent(0.5)
                    button.contentHorizontalAlignment = .leading
                    return config
                }
            }
        }
    }

    private var filterSelectionColumn: some View {
        ScrollView {
            LazyVStack {
                let predicates = viewModel.availablePredicates[viewModel.selectedCategory] ?? []
                ForEach(predicates, id: \.localizedDescription) { predicate in
                    let isSelected = viewModel.selectedPredicates.contains(predicate)
                    AnimatableButton(
                        layoutOptions: [.expandHorizontally, .respectIntrinsicHeight]
                    ) {
                        viewModel.togglePredicate(predicate: predicate)
                    } configuration: { button in
                        var config = UIButton.Configuration.plain()
                        config.title = predicate.localizedDescription
                        config.baseForegroundColor = .label
                        config.imagePadding = 5
                        config.attributedTitle = .init(predicate.localizedDescription, font: .systemFont(ofSize: 14))
                        config.image = if isSelected {
                            TimetableAsset.checkmarkCircleTick.image
                        } else {
                            TimetableAsset.checkmarkCircleUntick.image
                        }
                        button.contentHorizontalAlignment = .leading
                        return config
                    }
                }
            }
        }
        .introspect(.scrollView, on: .iOS(.v17, .v18)) { scrollView in
            scrollView.makeTouchResponsive()
        }
    }

    private var filterApplyButton: some View {
        AnimatableButton(
            layoutOptions: [.expandHorizontally]
        ) {
            dismiss()
            Task {
                await viewModel.fetchInitialSearchResult()
            }
        } configuration: { button in
            var config = UIButton.Configuration.borderedProminent()
            config.baseBackgroundColor = TimetableAsset.cyan.color
            config.attributedTitle = .init(TimetableStrings.searchFilterApply, font: .systemFont(ofSize: 17, weight: .semibold))
            config.contentInsets = .init(.all(10))
            return config
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var isPresented = true
    ZStack {
        Color.gray
        Button("Present") {
            isPresented = true
        }
        .buttonStyle(.borderedProminent)
    }
    .ignoresSafeArea()
    .sheet(isPresented: $isPresented) {
        SearchFilterSheet(viewModel: .init())
    }
}
