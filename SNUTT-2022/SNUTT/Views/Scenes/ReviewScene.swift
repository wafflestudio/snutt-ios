//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

struct ReviewScene: View {
    // for test
    @StateObject var viewModel = ReviewViewModel()

    var body: some View {
        Button {
            viewModel.updateTimetable(timeTable: AppState.CurrentTimetable())
        } label: {
            Text("Change current timetable")
        }

        let _ = debugChanges()
    }
}

struct ReviewScene_Previews: PreviewProvider {
    static var previews: some View {
        ReviewScene()
    }
}
