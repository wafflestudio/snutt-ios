//
//  LectureDiaryListView.swift
//  SNUTT
//
//  Created by 최유림 on 5/28/25.
//

import SwiftUI

struct LectureDiaryListView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    @State private var selectedSemester: String? = ""
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var yearAndSemesterList: [String] {
        Set(viewModel.diaryListCollection.map(\.yearAndSemester)).sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.diaryListCollection.isEmpty {
                EmptyView()
                    .environmentObject(viewModel)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(yearAndSemesterList, id: \.self) { semester in
                            SemesterChip(
                                semester: semester,
                                isSelected: semester == selectedSemester
                            ) {
                                selectedSemester = semester
                            }
                        }
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 12)
                .padding(.horizontal, 20)
                
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.diaryListCollection, id: \.year) {
                            ExpandableDiarySummaryCell(diaryList: $0.diaryList) { diaryId in
                                Task {
                                    await viewModel.deleteDiary(diaryId)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("강의 일기장")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSemester = yearAndSemesterList.first
        }
    }
}

extension LectureDiaryListView {
    struct EmptyView: View {
        
        @State private var lectureForDiary: Lecture?
        @State private var showDiaryNotAvailableAlert = false
        
        @Environment(\.colorScheme) private var colorScheme
        @EnvironmentObject var viewModel: ViewModel
        
        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                VStack(spacing: 24) {
                    Image("warning.cat.red")
                    VStack(spacing: 8) {
                        Text("강의일기장이 비어있어요.")
                            .font(STFont.semibold15.font)
                        Text("매주 마지막 수업날,\n푸시알림을 통해 강의일기를 작성해보세요!")
                            .lineHeight(with: STFont.regular13, percentage: 145)
                            .foregroundStyle(
                                colorScheme == .dark
                                ? STColor.gray30
                                : .primary.opacity(0.5)
                            )
                    }
                }
                .multilineTextAlignment(.center)
                Button {
                    Task {
                        lectureForDiary = await viewModel.getLectureForDiary()
                        if lectureForDiary == nil {
                            showDiaryNotAvailableAlert = true
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text("강의일기 작성하기")
                            .font(STFont.regular15.font)
                        Image("daily.review.chevron.right")
                    }
                    .padding([.vertical, .trailing], 12)
                    .padding(.leading, 20)
                }
                .buttonBorderShape(.capsule)
                .foregroundStyle(.primary)
                .overlay(
                    Capsule().stroke(
                        colorScheme == .dark
                        ? STColor.gray30.opacity(0.4)
                        : STColor.border
                    )
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert(
                "강의일기장을 작성할 수 있는 강의가 없습니다.",
                isPresented: $showDiaryNotAvailableAlert
            ) {}
            .fullScreenCover(item: $lectureForDiary) { lecture in
                EditLectureDiaryScene(
                    viewModel: .init(container: viewModel.container),
                    lecture: lecture
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        LectureDiaryListView(viewModel: .init(container: .preview))
    }
}
#endif

extension LectureDiaryListView {
    class ViewModel: BaseViewModel, ObservableObject {
        #if DEBUG
        @Published var diaryListCollection: [DiaryListPerSemester] = [
//            .init(
//                year: 2025,
//                semester: .second,
//                diaryList: [
//                    .preview1, .preview2
//                ]
//            )
        ]
        #else
        @Published var diaryListCollection: [DiaryListPerSemester] = []
        #endif
        
        override init(container: DIContainer) {
            super.init(container: container)
        }
        
        func getLectureForDiary() async -> Lecture? {
            guard let targetMetaData = services.lectureService.getCurrentOrNextSemesterPrimaryTable()
            else { return nil }
            do {
                let targetTable = try await services.timetableService.fetchTimetableData(timetableId: targetMetaData.id)
                return targetTable.lectures.first { $0.lectureId != nil }
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return nil
            }
        }
        
        func getDiaryListCollection() async {
            do {
                let collection = try await services.diaryService.fetchDiaryList()
                self.diaryListCollection = collection
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
        
        func deleteDiary(_ id: String) async {
            do {
                try await services.diaryService.deleteDiary(id)
                diaryListCollection = diaryListCollection.map { summaryList in
                    var newSummaryList = summaryList
                    newSummaryList.diaryList = summaryList.diaryList.filter { $0.id != id }
                    return newSummaryList
                }
                .filter { !$0.diaryList.isEmpty }
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}
