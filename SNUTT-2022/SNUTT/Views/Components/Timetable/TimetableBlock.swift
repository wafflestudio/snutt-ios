//
//  TimetableBlock.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlock: View {
    let lecture: Lecture
    let timePlace: TimePlace

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.orange)
                .border(Color.black.opacity(0.1), width: 0.5)
            VStack {
                Group {
                    Text(lecture.title)
                    Text(timePlace.place)
                }
                .multilineTextAlignment(.center)
                .font(STFont.details)
                .foregroundColor(.white)
            }.padding(2)
        }
    }
}

struct TimetableBlock_Previews: PreviewProvider {
    static var previews: some View {
        let lecture = DummyAppState.shared.lectures.first!
        TimetableBlock(lecture: lecture, timePlace: lecture.timePlaces[0])
            .frame(width: 70, height: 100, alignment: .center)
    }
}
