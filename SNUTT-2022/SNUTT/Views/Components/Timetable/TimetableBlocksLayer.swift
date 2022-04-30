//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocksLayer: View {
    
    let viewModel: TimetableViewModel
    
    var body: some View {
        GeometryReader { reader in
            ForEach(viewModel.lectures) { lecture in
                ForEach(lecture.timePlaces) { timePlace in
                    if let offsetPoint = viewModel.getOffset(of: timePlace, in: reader.size) {
                        TimetableBlock(lecture: lecture, timePlace: timePlace)
                            .frame(width: viewModel.getWeekWidth(in: reader.size), height: viewModel.getHeight(of: timePlace, in: reader.size), alignment: .center)
                            .offset(x: offsetPoint.x, y: offsetPoint.y)
                    }
                }
            }
        }
    }
}

struct TimetableBlocks_Previews: PreviewProvider {
    
    
    static var previews: some View {
        ZStack {
            let viewModel = TimetableViewModel()
            TimetableBlocksLayer(viewModel: viewModel)
            TimetableGridLayer(viewModel: viewModel)
        }
        
    }
}
