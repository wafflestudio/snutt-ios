//
//  TimetableZStack.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableZStack: View {
    let current: Timetable?
    let config: TimetableConfiguration

    var body: some View {
        ZStack {
            TimetableGridLayer(current: current, config: config)
            TimetableBlocksLayer(current: current, config: config)
        }
        .background(STColor.systemBackground)

        let _ = debugChanges()
    }
}

// struct TimetableStack_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = TimetableViewModel(container: .preview)
//        TimetableZStack(viewModel: .init(container: viewModel.container))
//            .environmentObject(viewModel.timetableState)
//    }
// }
