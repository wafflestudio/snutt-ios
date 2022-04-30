//
//  LectureDetailList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import SwiftUI

struct LectureDetails: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Text("This is LectureDetails View.")
            .onAppear {
                self.appState.showActivityIndicator = !self.appState.showActivityIndicator
            }
    }
}

struct LectureDetailList_Previews: PreviewProvider {
    static var previews: some View {
        LectureDetails()
    }
}
