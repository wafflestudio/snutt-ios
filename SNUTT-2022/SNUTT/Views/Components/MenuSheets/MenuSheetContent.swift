//
//  MenuSheetContent.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct MenuSheetContent: View {
    let viewModel: ViewModel
    @ObservedObject var timetableState: TimetableState

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        timetableState = self.viewModel.timetableState
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                let timetablesByQuarter = viewModel.timetablesByQuarter
                ForEach(Array(timetablesByQuarter.keys.sorted().reversed()), id: \.self) { quarter in
                    MenuSection(quarter: quarter, isExpanded: quarter.year == 2022) {
                        ForEach(timetablesByQuarter[quarter] ?? [], id: \.id) { data in
                            MenuSectionRow(timetableMetadata: data,
                                           isSelected: viewModel.currentTimetable?.id == data.id,
                                           selectTimetable: viewModel.selectTimetable,
                                           duplicateTimetable: viewModel.duplicateTimetable,
                                           openEllipsis: viewModel.openEllipsis
                            )
                        }
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

extension MenuSheetContent {
    class ViewModel: BaseViewModel {
        var timetableState: TimetableState {
            appState.timetable
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
                services.appService.presentErrorAlert(error: error.asSTError)
            }
        }
        
        func duplicateTimetable(timetableId: String) async {
            do {
                try await services.timetableService.copyTimetable(timetableId: timetableId)
            } catch {
                services.appService.presentErrorAlert(error: error.asSTError)
            }
        }
        
        func openEllipsis(for timetable: TimetableMetadata) {
            services.appService.openEllipsis(for: timetable)
        }
    }
}

struct MenuSheetContent_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetContent(viewModel: .init(container: .preview))
    }
}
