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
    let theme: Theme

    var body: some View {
        ZStack {
            Rectangle()
                .fill(lecture.getColor(with: theme).bg)
                .border(Color.black.opacity(0.1), width: 0.5)

            VStack(spacing: 0) {
                Group {
                    Text(lecture.title)
                        .font(STFont.details)

                    Text(timePlace.place)
                        .font(STFont.detailsSemibold)
                        .padding(2)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
                .multilineTextAlignment(.center)
                .foregroundColor(lecture.getColor(with: theme).fg)
            }.padding(2)
        }

        let _ = debugChanges()
    }
}

//
// struct TimetableBlock_Previews: PreviewProvider {
//    static var previews: some View {
//        let lecture: Lecture = .preview
//        NavigationView {
//            TimetableBlock(viewModel: .init(container: .preview),
//                           lecture: lecture,
//                           timePlace: lecture.timePlaces[0],
//                           theme: .snutt)
//            .frame(width: 70, height: 100, alignment: .center)
//        }
//    }
// }
