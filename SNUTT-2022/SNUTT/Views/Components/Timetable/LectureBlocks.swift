//
//  LectureBlocks.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import SwiftUI

struct LectureBlocks: View {
    typealias Painter = TimetableViewModel.TimetablePainter
    let lecture: Lecture
    let theme: Theme
    let config: TimetableConfiguration
    
    @Environment(\.dependencyContainer) var container: DIContainer?
    
    var body: some View {
        GeometryReader { reader in
            ForEach(lecture.timePlaces) { timePlace in
                if let offsetPoint = Painter.getOffset(of: timePlace,
                                                       in: reader.size,
                                                       timetableState: config)
                {
                    Group {
                        if let container = container {
                            NavigationLink(destination: LectureDetailScene(viewModel: .init(container: container), lecture: lecture)) {
                                TimetableBlock(lecture: lecture,
                                               timePlace: timePlace,
                                               theme: theme)
                            }
                            .buttonStyle(.plain)
                        } else {
                            TimetableBlock(lecture: lecture,
                                           timePlace: timePlace,
                                           theme: theme)
                        }
                    }
                    .frame(width: Painter.getWeekWidth(in: reader.size, weekCount: config.weekCount), height: Painter.getHeight(of: timePlace, in: reader.size, hourCount: config.hourCount), alignment: .center)
                    .offset(x: offsetPoint.x, y: offsetPoint.y)
                }
            }
        }
        let _ = debugChanges()
    }
    
}

extension LectureBlocks {
    class ViewModel: BaseViewModel {}
}

//struct LectureBlocks_Previews: PreviewProvider {
//    static var previews: some View {
//        let viewModel = TimetableViewModel(container: .preview)
//        LectureBlocks(viewModel: .init(container: .preview), lecture: .preview)
//            .environmentObject(viewModel.timetableState)
//    }
//}
