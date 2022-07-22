//
//  MenuSheetContent.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/22.
//

import SwiftUI

struct MenuSheetContent: View {
    let viewModel: ViewModel
    @ObservedObject var timetableSetting: TimetableSetting
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        timetableSetting = self.viewModel.timetableSetting
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
                                           selectTimetable: viewModel.fetchTimetable)
                        }
                    }
                }
            }
        }
    }
}

extension MenuSheetContent {
    class ViewModel: BaseViewModel {
        var timetableSetting: TimetableSetting {
            appState.setting.timetableSetting
        }
        
        var timetablesByQuarter: [Quarter: [TimetableMetadata]] {
            return Dictionary(grouping: timetableSetting.metadataList ?? [], by: { $0.quarter })
        }
        
        var currentTimetable: Timetable? {
            appState.setting.timetableSetting.current
        }
        
        func fetchTimetable(timetableId: String) async {
            do {
                try await services.timetableService.fetchTimetable(timetableId: timetableId)
            } catch {
                // TODO: handle error
            }
        }
        
    }
}

struct MenuSheetContent_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetContent(viewModel: .init(container: .preview))
    }
}
