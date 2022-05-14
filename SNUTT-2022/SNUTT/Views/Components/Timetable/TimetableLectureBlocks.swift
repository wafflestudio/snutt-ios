//
//  TimetableLectureBlocks.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/14.
//

import SwiftUI

struct TimetableLectureBlocks: View {
    let lecture: Lecture
    let timetableSize: CGSize

    let getOffset: (_ of: TimePlace, _ in: CGSize) -> CGPoint?
    let getWeekWidth: (_ in: CGSize) -> CGFloat
    let getHeight: (_ of: TimePlace, _ in: CGSize) -> CGFloat

    var body: some View {
        ForEach(lecture.timePlaces) { timePlace in
            if let offsetPoint = getOffset(timePlace, timetableSize) {
                TimetableBlock(lecture: lecture, timePlace: timePlace)
                    .frame(width: getWeekWidth(timetableSize), height: getHeight(timePlace, timetableSize), alignment: .center)
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
            }
        }
    }
}

// struct TimetableLectureBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        TimetableLectureBlocks()
//    }
// }
