//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    let viewModel: ViewModel
    @EnvironmentObject var timetableSetting: TimetableSetting

    var body: some View {
        ForEach(timetableSetting.current?.lectures ?? []) { lecture in
            LectureBlocks(viewModel: .init(container: viewModel.container), lecture: lecture)
        }

        let _ = debugChanges()
    }
}

extension TimetableBlocksLayer {
    class ViewModel: BaseViewModel {}
}

struct TimetableBlocks_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            let viewModel = TimetableViewModel(container: .preview)
            TimetableBlocksLayer(viewModel: .init(container: .preview))
                .environmentObject(viewModel.timetableSetting)
        }
    }
}
