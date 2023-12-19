//
//  BookmarkScene.swift
//  SNUTT
//
//  Created by 이채민 on 2023/01/21.
//

import SwiftUI

struct BookmarkScene: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.bookmarkedLectures.isEmpty {
                EmptyBookmarkList()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ExpandableLectureList(
                    viewModel: .init(container: viewModel.container),
                    lectures: viewModel.bookmarkedLectures,
                    selectedLecture: $viewModel.selectedLecture)
                .animation(.customSpring, value: viewModel.selectedLecture?.id)
            }
        }
        .navigationTitle("관심강좌")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.customSpring, value: viewModel.bookmarkedLectures.count)
    }
}

extension BookmarkScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published private var _selectedLecture: Lecture?
        @Published var bookmarkedLectures: [Lecture] = []

        override init(container: DIContainer) {
            super.init(container: container)

            appState.search.$selectedLecture.assign(to: &$_selectedLecture)
            appState.timetable.$bookmark.compactMap {
                $0?.lectures
            }.assign(to: &$bookmarkedLectures)
        }

        var selectedLecture: Lecture? {
            get { _selectedLecture }
            set { services.searchService.setSelectedLecture(newValue) }
        }
    }
}

struct EmptyBookmarkList: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("추가한 관심강좌가 없습니다.")
                .font(STFont.title)
            Spacer().frame(height: 6)
            Text("고민되는 강의를 관심강좌에 추가하여\n관리해보세요.")
                .font(.system(size: 17, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .foregroundColor(STColor.whiteTranslucent)
    }
}

#if DEBUG
    struct BookmarkScene_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                BookmarkScene(viewModel: .init(container: .preview))
            }
        }
    }
#endif
