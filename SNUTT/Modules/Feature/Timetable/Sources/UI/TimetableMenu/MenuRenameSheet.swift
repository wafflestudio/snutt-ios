//
//  MenuRenameSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents

struct MenuRenameSheet: View {
    let viewModel: TimetableMenuViewModel

    @State private var title: String = ""
    @FocusState private var searchFocus: Bool

    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 20) {
                SheetTopBar(cancel: {
                    dismiss()
                }, confirm: {

                })

                AnimatableTextField(label: "시간표 제목", placeholder: "시간표 제목을 입력하세요", text: $title)
                    .focused($searchFocus)
                    .onAppear {
                        searchFocus = true
                    }
                    .padding()
            }
        }
        .presentationDetents([.height(130)])
    }
}

#Preview {
    MenuRenameSheet(viewModel: .init(timetableViewModel: .init()))
}
