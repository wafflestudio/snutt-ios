//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    let lectures: [Lecture]
    let getOffset: (_ of: TimePlace, _ in: CGSize) -> CGPoint?
    let getWeekWidth: (_ in: CGSize) -> CGFloat
    let getHeight: (_ of: TimePlace, _ in: CGSize) -> CGFloat

    var body: some View {
        GeometryReader { reader in
            ForEach(lectures) { lecture in
                TimetableLectureBlocks(lecture: lecture, timetableSize: reader.size, getOffset: getOffset, getWeekWidth: getWeekWidth, getHeight: getHeight)
            }
        }
    }
}

// struct TimetableBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack {
//            let viewModel = TimetableViewModel()
//            TimetableBlocksLayer(viewModel: viewModel)
//            TimetableGridLayer(viewModel: viewModel)
//        }
//    }
// }
