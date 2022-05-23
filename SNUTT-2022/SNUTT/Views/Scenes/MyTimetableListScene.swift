//
//  MyTimetableListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

struct MyTimetableListScene: View {
    @ObservedObject var viewModel: TimetableViewModel
    
    var body: some View {
        TimetableList(viewModel: viewModel)
    }
}

//
// struct MyTimetableListScene_Previews: PreviewProvider {
//    static var previews: some View {
//        MyTimetableListScene().environmentObject(AppState())
//    }
// }
