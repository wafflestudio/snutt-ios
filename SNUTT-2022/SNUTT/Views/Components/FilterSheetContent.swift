//
//  FilterSheetContent.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/27.
//

import SwiftUI

struct FilterSheetContent: View {
    @ObservedObject var viewModel: FilterSheetViewModel
    @State private var selectedCategory: SearchTagType = .sortCriteria
    @State private var isTimeRangeSheetOpen: Bool = false

    struct FilterButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .contentShape(Rectangle())
                .background(configuration.isPressed ? STColor.cyan.opacity(0.8) : STColor.cyan)
        }
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                VStack(spacing: 25) {
                    ForEach(SearchTagType.allCases, id: \.self) { tag in
                        let isSelected = selectedCategory == tag
                        Button {
                            selectedCategory = tag
                        } label: {
                            Spacer()
                            Text(tag.typeStr)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(isSelected ? Color(uiColor: .label) : Color(uiColor: .label.withAlphaComponent(0.5)))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: 110, maxHeight: .infinity, alignment: .topLeading)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)

                ScrollView {
                    LazyVStack {
                        if selectedCategory == .department {
                            ForEach(viewModel.pinnedTagList) {
                                tag in FilterTagButton(tag: tag, isPinned: true, viewModel: viewModel, isTimeRangeSheetOpen: $isTimeRangeSheetOpen)
                            }
                            Divider()
                        }
                        ForEach(viewModel.filterTags(with: selectedCategory)) { tag in
                            FilterTagButton(tag: tag, isPinned: false, viewModel: viewModel, isTimeRangeSheetOpen: $isTimeRangeSheetOpen)
                        }
                    }
                }
                .id(selectedCategory) // rerender on change of category
                .padding(.trailing)
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.03),
                    .init(color: .black, location: 0.97),
                    .init(color: .clear, location: 1),
                ]), startPoint: .top, endPoint: .bottom))
            }

            Button {
                viewModel.isFilterOpen = false
                Task {
                    await viewModel.fetchInitialSearchResult()
                }
            } label: {
                Text("필터 적용")
                    .foregroundColor(.white)
                    .font(STFont.bold17.font)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            .buttonStyle(FilterButtonStyle())
            .padding(.top, 10)
        }
        .sheet(isPresented: $isTimeRangeSheetOpen) {
            if let timetable = viewModel.currentTimetable {
                NavigationView {
                    TimeRangeSelectionSheet(currentTimetable: timetable, selectedTimeRange: $viewModel.selectedTimeRange) {
                        viewModel.selectTimeRangeTag()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                .foregroundColor(.primary)
                .interactiveDismissDisabled()
                .ignoresSafeArea(.keyboard)
            }
        }
    }
}

struct FilterTagButton: View {
    let tag: SearchTag
    let isPinned: Bool
    @ObservedObject var viewModel: FilterSheetViewModel
    @Binding var isTimeRangeSheetOpen: Bool

    var body: some View {
        Button {
            viewModel.toggle(tag)
        } label: {
            HStack(alignment: .top) {
                Image("checkmark.circle.\(viewModel.isSelected(tag: tag) ? "tick" : "untick")")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16)
                    .padding(.trailing, 3)
                VStack(alignment: .leading, spacing: 6) {
                    Text(tag.text)
                        .font(STFont.regular14.font)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())

                    if tag.text == TimeType.range.rawValue {
                        Group {
                            if !viewModel.selectedTimeRange.isEmpty {
                                Text(viewModel.selectedTimeRange.map {
                                    $0.preciseTimeString
                                }.joined(separator: "\n"))
                                    .underline()
                                    .lineSpacing(4)
                            } else {
                                Text("눌러서 선택하기")
                                    .underline()
                            }
                        }
                        .font(STFont.regular12.font)
                        .foregroundColor(STColor.darkGray)
                        .onTapGesture { isTimeRangeSheetOpen = true }
                    }
                }
                if isPinned {
                    Image("department.xmark")
                        .onTapGesture { viewModel.removePin(tag: tag) }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 7)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
    struct FilterSheetContent_Previews: PreviewProvider {
        static var previews: some View {
            FilterSheetContent(viewModel: .init(container: .preview))
        }
    }
#endif
