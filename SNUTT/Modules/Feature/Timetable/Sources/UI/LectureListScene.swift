//
//  LectureListScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct LectureListScene: View {
    @ObservedObject var viewModel: TimetableViewModel
    var body: some View {
        EmptyView()
    }
}

#Preview {
    LectureListScene(viewModel: .init())
}
