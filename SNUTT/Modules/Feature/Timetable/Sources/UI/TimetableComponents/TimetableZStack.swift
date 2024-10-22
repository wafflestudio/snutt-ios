//
//  TimetableZStack.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct TimetableZStack: View {
    @ObservedObject var viewModel: TimetableViewModel

    var body: some View {
        ZStack {
            TimetableGridLayer(viewModel: viewModel)
            TimetableBlocksLayer(viewModel: viewModel)
        }
    }
}

#Preview {
    let timetable: any Timetable = PreviewTimetable.preview
    let viewModel = {
        let viewModel = TimetableViewModel()
        viewModel.currentTimetable = timetable
        return viewModel
    }()
    TimetableZStack(viewModel: viewModel)
}
