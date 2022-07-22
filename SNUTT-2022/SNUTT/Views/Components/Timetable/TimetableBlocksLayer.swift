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
    @Environment(\.selectedLecture) var selectedLecture: Lecture?

    var body: some View {
        ForEach(viewModel.lectures) { lecture in
            LectureBlocks(viewModel: .init(container: viewModel.container), lecture: lecture)
        }
        
        if var selectedLecture = selectedLecture {
            LectureBlocks(viewModel: .init(container: viewModel.container), lecture: selectedLecture.withTemporaryColor())
        }

        let _ = debugChanges()
    }
}

extension TimetableBlocksLayer {
    class ViewModel: BaseViewModel {
        var lectures: [Lecture] {
            appState.setting.timetableSetting.current?.lectures ?? []
        }
    }
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
