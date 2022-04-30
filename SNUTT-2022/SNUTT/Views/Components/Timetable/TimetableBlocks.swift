//
//  TimetableBlock.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/04/30.
//

import SwiftUI

struct TimetableBlocks: View {
    
    let viewModel: TimetableViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TimetableBlock_Previews: PreviewProvider {
    static var previews: some View {
        TimetableBlocks(viewModel: TimetableViewModel())
    }
}
