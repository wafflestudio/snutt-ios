//
//  FilterSheetContent.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/27.
//

import SwiftUI

struct FilterSheetContent: View {
    let viewModel: FilterSheetViewModel
    @State var selectedCategory: SearchTagType = .classification
    @ObservedObject var searchState: SearchState

    init(viewModel: FilterSheetViewModel) {
        self.viewModel = viewModel
        searchState = self.viewModel.searchState
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
                                .background(STColor.sheetBackground)
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
                                    withAnimation(.customSpring) {
                                        viewModel.toggle(tag)
                                    }
                                } label: {
                                    HStack {
                                        Image("checkmark.circle.\(viewModel.isSelected(tag: tag) ? "tick" : "untick")")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16)
                                            .padding(.trailing, 3)
                                        Text(tag.text)
                                            .font(.system(size: 14))
                                            .frame(maxWidth: .infinity, alignment: .leading)
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
                viewModel.toggleFilterSheet()
                Task {
                    await viewModel.fetchInitialSearchResult()
                }
            } label: {
                Text("필터 적용")
                    .font(.system(size: 17, weight: .bold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .padding(.bottom, 10)
            .tint(STColor.cyan)
            
            
        }
    }
}

struct FilterSheetContent_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetContent(viewModel: .init(container: .preview))
    }
}

