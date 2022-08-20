//
//  MenuSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct MenuSheet: View {
    let viewModel: ViewModel
    var isOpen: Binding<Bool>
    @ObservedObject var timetableState: TimetableState

    init(viewModel: ViewModel, isOpen: Binding<Bool>) {
        self.viewModel = viewModel
        self.isOpen = isOpen
        timetableState = self.viewModel.timetableState
    }

    var body: some View {
        Sheet(isOpen: isOpen, orientation: .left(maxWidth: 320), cornerRadius: 0, sheetOpacity: 0.7) {
            VStack(spacing: 0) {
                HStack {
                    Logo(orientation: .horizontal)
                        .padding(.vertical)
                    Spacer()
                    Button {
                        viewModel.toggleMenuSheet()
                    } label: {
                        Image("xmark.black")
                    }
                }
                .padding(.horizontal, 20)

                Divider()
                    .padding(.horizontal, 10)

                ScrollView {
                    LazyVStack(spacing: 15) {
                        let timetablesByQuarter = viewModel.timetablesByQuarter
                        
                        if viewModel.services.timetableService.isNewCourseBookAvailable() {
                            // 새로운 수강편람이 나와 있음을 알린다.
                        }
                        
                        Button {
                            Task {
                                await viewModel.createTimetable()
                            }
                        } label: {
                            Text("새로운 시간표 생성")
                        }

                        
                        ForEach(Array(timetablesByQuarter.keys.sorted().reversed()), id: \.self) { quarter in
                            MenuSection(quarter: quarter, current: timetableState.current) {
                                ForEach(timetablesByQuarter[quarter] ?? [], id: \.id) { data in
                                    MenuSectionRow(timetableMetadata: data,
                                                   isSelected: viewModel.currentTimetable?.id == data.id,
                                                   selectTimetable: viewModel.selectTimetable,
                                                   duplicateTimetable: viewModel.duplicateTimetable,
                                                   openEllipsis: viewModel.openEllipsis)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .animation(.customSpring, value: timetableState.metadataList)
        }
    }
}

extension MenuSheet {
    class ViewModel: BaseViewModel {
        var timetableState: TimetableState {
            appState.timetable
        }

        func toggleMenuSheet() {
            services.appService.toggleMenuSheet()
        }

        var timetablesByQuarter: [Quarter: [TimetableMetadata]] {
            return Dictionary(grouping: timetableState.metadataList ?? [], by: { $0.quarter })
        }

        var currentTimetable: Timetable? {
            appState.timetable.current
        }

        func selectTimetable(timetableId: String) async {
            do {
                await services.searchService.initializeSearchState()
                try await services.timetableService.fetchTimetable(timetableId: timetableId)
            } catch {
                services.appService.presentErrorAlert(error: error)
            }
        }

        func duplicateTimetable(timetableId: String) async {
            do {
                try await services.timetableService.copyTimetable(timetableId: timetableId)
            } catch {
                services.appService.presentErrorAlert(error: error)
            }
        }
        
        func createTimetable() async {
            do {
                try await services.timetableService.createTimetable(title: "12345", quarter: .init(year: 2022, semester: Semester.second))
                try await services.timetableService.fetchRecentTimetable()
            } catch {
                services.appService.presentErrorAlert(error: error)
            }
        }

        func openEllipsis(for timetable: TimetableMetadata) {
            services.appService.openEllipsis(for: timetable)
        }
    }
}

struct MenuSheetContent_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheet(viewModel: .init(container: .preview), isOpen: .constant(true))
    }
}
