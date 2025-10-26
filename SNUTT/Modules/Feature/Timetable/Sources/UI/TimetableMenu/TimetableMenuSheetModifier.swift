//
//  TimetableMenuSheetModifier.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

extension View {
    func timetableMenuSheet(
        isPresented: Binding<Bool>,
        viewModel: TimetableViewModel
    ) -> some View {
        customSheet(
            isPresented: isPresented,
            configuration: .init(
                orientation: .left(maxWidth: 320),
                cornerRadius: 0,
                sheetOpacity: 0.7
            )
        ) {
            TimetableMenuContentView(timetableViewModel: viewModel)
                .analyticsScreen(.timetableMenu)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    let viewModel = TimetableViewModel()
    let _ = Task {
        try await viewModel.loadTimetableList()
    }

    ZStack {
        Color.black.opacity(0.1).ignoresSafeArea()
        Button("Show Timetable Menu: \(isPresented)") {
            isPresented.toggle()
        }
        .timetableMenuSheet(isPresented: $isPresented, viewModel: viewModel)
    }
    .overlaySheet()
}
