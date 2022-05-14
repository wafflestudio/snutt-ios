//
//  TimetableZStack.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableZStack: View {
    let viewModel: TimetableViewModel
    var body: some View {
        ZStack {
            TimetableGridLayer(viewModel: viewModel)
            TimetableBlocksLayer(lectures: viewModel.lectures, getOffset: viewModel.getOffset, getWeekWidth: viewModel.getWeekWidth, getHeight: viewModel.getHeight)
        }
    }
}

struct TimetableStack_Previews: PreviewProvider {
    static var previews: some View {
        TimetableZStack(viewModel: TimetableViewModel())
    }
}
