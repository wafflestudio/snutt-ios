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

                ScrollViewReader { _ in
                    ScrollView {
                        VStack(spacing: 15) {
                            let timetablesByQuarter = viewModel.timetablesByQuarter

                            HStack {
                                if viewModel.services.timetableService.isNewCourseBookAvailable() {
                                    // 새로운 수강편람이 나와 있음을 알린다.
                                    Circle()
                                        .frame(width: 7, height: 7)
                                        .foregroundColor(.red)
                                }

                                Spacer()

                                Button {
                                    viewModel.openCreateSheet()
                                } label: {
                                    Text("+ 시간표 추가하기")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                            }
                            .padding(.horizontal, 15)

                            ForEach(Array(timetablesByQuarter.keys.sorted().reversed()), id: \.self) { quarter in
                                MenuSection(quarter: quarter, current: timetableState.current) {
                                    ForEach(timetablesByQuarter[quarter] ?? [], id: \.id) { timetable in
                                        MenuSectionRow(timetableMetadata: timetable,
                                                       isSelected: viewModel.currentTimetable?.id == timetable.id,
                                                       selectTimetable: viewModel.selectTimetable,
                                                       duplicateTimetable: viewModel.duplicateTimetable,
                                                       openEllipsis: viewModel.openEllipsis)
                                    }
                                }
                                // in extreme cases, there might be hash collision
                                .id(quarter.hashValue)
                            }
                        }
                        .padding(.top, 20)
                        .animation(.customSpring, value: timetableState.metadataList)
                    }
                    // TODO: 새로운 시간표 생성했을 때 해당 위치로 스크롤하기
//                    .onChange(of: menuState.onCreateToggle) { _ in
//                        // due to Apple's bug, customSpring animation doesn't work for now
//                        withAnimation(.customSpring) {
//                            reader.scrollTo(timetableState.current?.quarter.hashValue, anchor: .bottom)
//                        }
//                    }
                }
            }
        }
    }
}

extension MenuSheet {
    class ViewModel: BaseViewModel {
        var timetableState: TimetableState {
            appState.timetable
        }

        var menuState: MenuState {
            appState.menu
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

        func openCreateSheet() {
            services.appService.openCreateSheet()
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
