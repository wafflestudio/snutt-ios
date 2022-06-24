//
//  TimetableZStack.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableZStack: View {
    let drawing: TimetableViewModel.TimetableDrawing

    var body: some View {
        ZStack {
            TimetableGridLayer(drawing: drawing)
            TimetableBlocksLayer(drawing: drawing)
        }

        let _ = debugChanges()
    }
}

//
// struct TimetableStack_Previews: PreviewProvider {
//    static var previews: some View {
////        TimetableZStack(viewModel: TimetableViewModel())
//    }
// }
