//
//  MyTimetableListScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI

struct MyTimetableListScene: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TimetableList(lectures: appState.currentTimetable.lectures).onAppear {
            print("Main List Page...showActivityIndicator: \(appState.system.showActivityIndicator)")
        }
    }
}

//
// struct MyTimetableListScene_Previews: PreviewProvider {
//    static var previews: some View {
//        MyTimetableListScene().environmentObject(AppState())
//    }
// }
