//
//  EditableFields.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/17.
//

import SwiftUI
import Combine


struct EditableTextField: View {
    @Binding var text: String
    @State var height: CGFloat = 0
    var readOnly: Bool = false
    var multiLine: Bool = false
    @Environment(\.editMode) private var editMode

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        if multiLine {
            UITextEditor("(없음)", text: $text) { textView in
                textView.backgroundColor = .clear
                textView.textContainerInset = .zero
                textView.textContainer.lineFragmentPadding = 0
                textView.font = .systemFont(ofSize: 16, weight: .regular)
            } onChange: { textView in
                height = textView.contentSize.height
            }
            .frame(height: height)
            .disabled(!isEditing || readOnly)
        } else {
            TextField("(없음)", text: $text)
                .foregroundColor(readOnly ? STColor.disabled : Color(uiColor: .label))
                .disabled(!isEditing || readOnly)
                .font(.system(size: 16, weight: .regular))
        }
    }
}

extension EditableTextField {
    /// Custom initializer to support editing `place` of a `Lecture`.
    ///
    /// 주어진 `timePlace`의 인자와 id가 같은 `TimePlace` 객체의 `place` 속성만 수정되도록 Binding을 재정의한다.
    init(lecture: Binding<Lecture>, timePlace: TimePlace) {
        _text = Binding(get: {
            guard let firstItem = lecture.wrappedValue.timePlaces.first(where: { $0.id == timePlace.id }) else { return "" }
            return String(firstItem.place)
        }, set: {
            guard let firstIndex = lecture.wrappedValue.timePlaces.firstIndex(where: { $0.id == timePlace.id }) else { return }
            lecture.wrappedValue.timePlaces[firstIndex].place = $0
        })
    }
}

struct EditableNumberField: View {
    @Binding var value: Int
    @Environment(\.editMode) private var editMode
    var readOnly: Bool = false

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        TextField("(없음)", value: $value, formatter: NumberFormatter())
            .disabled(!isEditing || readOnly)
            .foregroundColor(readOnly ? STColor.disabled : Color(uiColor: .label))
            .keyboardType(.numberPad)
            .onReceive(Just(value)) { newValue in
                let inputString = String(newValue)
                let filtered = inputString.filter { "0123456789".contains($0) }
                if filtered != inputString {
                    self.value = Int(filtered) ?? 0
                }
            }
            .font(.system(size: 16, weight: .regular))
    }
}

struct EditableTimeField: View {
    @Binding var lecture: Lecture
    var timePlace: TimePlace
    var action: () -> Void

    @Environment(\.editMode) private var editMode

    @ViewBuilder private func timeTextLabel(from timePlace: TimePlace) -> some View {
        Text("\(timePlace.day.shortSymbol) \(timePlace.startTimeString) ~ \(timePlace.endTimeString)")
    }

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        Button {
            action()
        } label: {
            timeTextLabel(from: timePlace)
                .font(.system(size: 16, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(!isEditing)
        .foregroundColor(Color(uiColor: .label))
    }
}
