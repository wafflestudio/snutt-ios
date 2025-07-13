//
//  TimePlaceEditableRow.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SwiftUI
import TimetableInterface

struct TimePlaceEditableRow: View {
    @Environment(LectureEditDetailViewModel.self) private var viewModel
    @Environment(\.editMode) private var editMode

    @Binding var timePlace: TimePlace

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                DetailLabel(text: "시간")
                DateTimeEditor(timePlace: $timePlace)
                    .disabled(!isEditing)
            }
            HStack {
                DetailLabel(text: "장소")
                TextField("장소", text: $timePlace.place, prompt: Text("(없음)"))
                    .foregroundStyle(Color.label)
                    .disabled(!isEditing)
            }
        }
    }
}
