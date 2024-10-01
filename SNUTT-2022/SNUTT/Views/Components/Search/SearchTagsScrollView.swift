//
//  SearchTagsScrollView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/04.
//

import SwiftUI

struct SearchTagsScrollView: View {
    let selectedTagList: [SearchTag]
    let deselect: @MainActor (SearchTag) -> Void

    @State private var previousTagCount: Int = 0

    var body: some View {
        ScrollViewReader { reader in
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedTagList) { tag in
                            Button(action: {
                                withAnimation(.customSpring) {
                                    deselect(tag)
                                }
                            }, label: {
                                HStack {
                                    Text(tag.text)
                                        .font(STFont.detailLabel.font)
                                    Image("xmark.white")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 10)
                                }
                            })
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .tint(tag.type.tagColor)
                            .id(tag.id)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
                Divider()
                    .frame(height: 1)
            }
            //            .background(.black.opacity(0.5))
            //            .background(.ultraThinMaterial)
            //            .padding(.top, 10)
            //            .padding(.bottom, 5)
            .onChange(of: selectedTagList.count, perform: { newValue in
                if newValue <= previousTagCount {
                    // no need to scroll when deselecting
                    previousTagCount = newValue
                    return
                }
                withAnimation(.customSpring) {
                    reader.scrollTo(selectedTagList.last?.id, anchor: .trailing)
                }
                previousTagCount = newValue
            })
        }
    }
}

struct SearchTags_Previews: PreviewProvider {
    static var previews: some View {
        SearchTagsScrollView(selectedTagList: [.init(id: .init(), type: .academicYear, text: "예시1"), .init(id: .init(), type: .classification, text: "예시2")], deselect: { _ in })
            .background(.black.opacity(0.2))
    }
}
