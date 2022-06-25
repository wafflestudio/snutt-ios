//
//  TimetableZStack.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableZStack: View {
    var body: some View {
        ZStack {
            TimetableGridLayer()
            TimetableBlocksLayer()
        }

        let _ = debugChanges()
    }
}

 struct TimetableStack_Previews: PreviewProvider {
    static var previews: some View {
        TimetableZStack()
    }
 }
