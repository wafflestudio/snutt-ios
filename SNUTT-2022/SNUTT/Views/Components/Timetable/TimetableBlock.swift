//
//  TimetableBlock.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlock: View {
    let viewModel: ViewModel
    let lecture: Lecture
    let timePlace: TimePlace
    let theme: Theme

    var body: some View {
        ZStack {
            NavigationLink(destination: LectureDetailScene(viewModel: .init(container: viewModel.container), lecture: lecture)) {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: theme.getColor(at: lecture.colorIndex)))
                        .border(Color.black.opacity(0.1), width: 0.5)

                    VStack {
                        Group {
                            Text(lecture.title)
                                .font(STFont.details)
                            Text(timePlace.place)
                                .font(STFont.detailsSemibold)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        .padding(2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    }.padding(2)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

extension TimetableBlock {
    class ViewModel: BaseViewModel {}
}

struct TimetableBlock_Previews: PreviewProvider {
    static var previews: some View {
        let lecture: Lecture = .preview
        NavigationView {
            TimetableBlock(viewModel: .init(container: .preview),
                           lecture: lecture,
                           timePlace: lecture.timePlaces[0],
                           theme: .snutt)
                .frame(width: 70, height: 100, alignment: .center)
        }
    }
}
