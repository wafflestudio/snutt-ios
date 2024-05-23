//
//  TimetableMenuSheetModifier.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents

extension View {
    func timetableMenuSheet(
        isPresented: Binding<Bool>,
        viewModel: TimetableViewModel
    ) -> some View {
        self
            .customSheet(
                isPresented: isPresented,
                configuration: .init(
                    orientation: .left(maxWidth: 320),
                    cornerRadius: 0,
                    sheetOpacity: 0.7
                )) {
                    TimetableMenuContentView(timetableViewModel: viewModel)
                }
    }
}

#Preview {
    @Previewable @State var isPresented = false
    @Previewable @State var context: SheetPresentationContext?
    let viewModel = TimetableViewModel()
    let _ = Task {
        try await viewModel.loadTimetableList()
    }

    ZStack {
        Button("Show Timetable Menu: \(isPresented)") {
            isPresented.toggle()
        }
        .timetableMenuSheet(isPresented: $isPresented, viewModel: viewModel)
        context?.makeSheet()
    }
    .onPreferenceChange(SheetPresentationKey.self) { value in
        context = value
    }
}
