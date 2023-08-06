//
//  FilterSheetContent.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/27.
//

import SwiftUI

struct FilterSheetContent: View {
    @ObservedObject var viewModel: FilterSheetViewModel
    @State private var selectedCategory: SearchTagType = .classification

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

                Divider()

                ScrollView {
                    LazyVStack {
                        Group {
                            ForEach(viewModel.filterTags(with: selectedCategory)) { tag in
                                Button {
                                    viewModel.toggle(tag)
                                } label: {
                                    HStack {
                                        Image("checkmark.circle.\(viewModel.isSelected(tag: tag) ? "tick" : "untick")")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16)
                                            .padding(.trailing, 3)
                                        Text(tag.text)
                                            .font(STFont.detailLabel)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .contentShape(Rectangle())
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 7)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity)
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
                    .font(STFont.title)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }
            .buttonStyle(FilterButtonStyle())
            .padding(.top, 10)
        }
    }
}

#if DEBUG
    struct FilterSheetContent_Previews: PreviewProvider {
        static var previews: some View {
            FilterSheetContent(viewModel: .init(container: .preview))
        }
    }
#endif
