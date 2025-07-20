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
                DetailLabel(text: TimetableStrings.editTimeLabel)
                DateTimeEditor(timePlace: $timePlace)
                    .disabled(!isEditing)
            }
            HStack {
                DetailLabel(text: TimetableStrings.editPlaceLabel)
                TextField(
                    TimetableStrings.editPlaceLabel,
                    text: $timePlace.place,
                    prompt: Text(TimetableStrings.editPlacePlaceholder)
                )
                .foregroundStyle(Color.label)
                .disabled(!isEditing)
            }
        }
    }
}
