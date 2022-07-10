//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    @EnvironmentObject var timetableSetting: TimetableSetting

    var body: some View {
        ForEach(timetableSetting.current?.lectures ?? []) { lecture in
            LectureBlocks(lecture: lecture)
        }

        let _ = debugChanges()
    }
}

struct TimetableBlocks_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            let viewModel = TimetableViewModel(container: .preview)
            TimetableBlocksLayer()
                .environmentObject(viewModel.timetableSetting)
        }
    }
}
