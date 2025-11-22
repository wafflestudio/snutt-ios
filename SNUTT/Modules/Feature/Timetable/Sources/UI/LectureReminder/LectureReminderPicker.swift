//
//  LectureReminderPicker.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

struct LectureReminderPicker: View {
    @Binding var selection: ReminderOption

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(ReminderOption.allCases, id: \.self) { option in
                Text(option.label)
                    .font(.system(size: 13, weight: selection == option ? .semibold : .medium))
                    .tag(option)
            }
        }
        .pickerStyle(.segmented)
    }
}

#Preview {
    @Previewable @State var selection: ReminderOption = .disabled

    LectureReminderPicker(selection: $selection)
        .padding()
}
