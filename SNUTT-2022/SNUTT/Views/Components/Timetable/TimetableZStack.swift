//
//  TimetableZStack.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableZStack: View {
    let viewModel: ViewModel
    var body: some View {
        ZStack {
            TimetableGridLayer()
            TimetableBlocksLayer(viewModel: .init(container: viewModel.container))
        }

        let _ = debugChanges()
    }
}

extension TimetableZStack {
    class ViewModel: BaseViewModel {}
}

struct TimetableStack_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = TimetableViewModel(container: .preview)
        TimetableZStack(viewModel: .init(container: viewModel.container))
            .environmentObject(viewModel.timetableSetting)
    }
}
