//
//  LectureDetailScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import Combine
import SwiftUI

struct LectureDetailScene: View {
    @ObservedObject var viewModel: ViewModel
    @State var lecture: Lecture
    @State private var editMode: EditMode = .inactive
    @State private var tempLecture: Lecture = .preview

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Group {
                    VStack {
                        Group {
                            HStack {
                                DetailLabel(text: "강의명")
                                EditableTextField(text: $lecture.title)
                            }
                            HStack {
                                DetailLabel(text: "교수")
                                EditableTextField(text: $lecture.instructor)
                            }
                            if lecture.isCustom {
                                HStack {
                                    DetailLabel(text: "학점")
                                    EditableNumberField(value: $lecture.credit)
                                }
                                HStack {
                                    DetailLabel(text: "비고")
                                    EditableTextField(text: $lecture.remark, multiLine: true)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .padding()

                    if !lecture.isCustom {
                        VStack {
                            Group {
                                HStack {
                                    DetailLabel(text: "학과")
                                    EditableTextField(text: $lecture.department)
                                }
                                HStack {
                                    DetailLabel(text: "학년")
                                    EditableTextField(text: $lecture.academicYear)
                                }
                                HStack {
                                    DetailLabel(text: "학점")
                                    EditableNumberField(value: $lecture.credit)
                                }
                                HStack {
                                    DetailLabel(text: "분류")
                                    EditableTextField(text: $lecture.classification)
                                }
                                HStack {
                                    DetailLabel(text: "구분")
                                    EditableTextField(text: $lecture.category)
                                }
                                HStack {
                                    DetailLabel(text: "강좌번호")
                                    EditableTextField(text: $lecture.courseNumber, readOnly: true)
                                }
                                HStack {
                                    DetailLabel(text: "분반번호")
                                    EditableTextField(text: $lecture.lectureNumber, readOnly: true)
                                }
                                HStack {
                                    DetailLabel(text: "비고")
                                    EditableTextField(text: $lecture.remark, multiLine: true)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        .padding()
                    }

                    VStack {
                        Text("시간 및 장소")
                            .padding(.leading, 5)
                            .font(STFont.detailLabel)
                            .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.8)))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(lecture.timePlaces) { timePlace in
                            VStack {
                                HStack {
                                    DetailLabel(text: "시간")
                                    EditableTimeField(lecture: $lecture, timePlace: timePlace)
                                }
                                Spacer()
                                    .frame(height: 5)
                                HStack {
                                    DetailLabel(text: "장소")
                                    EditableTextField(lecture: $lecture, timePlace: timePlace)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()

                    DetailButton(text: "강의계획서") {
                        print("tap")
                    }

                    DetailButton(text: "강의평") {
                        print("tap")
                    }

                    DetailButton(text: "삭제") {
                        print("tap")
                    }
                    .foregroundColor(.red)
                }
                .background(STColor.groupForeground)
            }
            .padding(.vertical, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode.isEditing)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if editMode.isEditing {
                    Button {
                        // cancel
                        lecture = tempLecture
                        editMode = .inactive
                        resignFirstResponder()
                    } label: {
                        Text("취소")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if editMode.isEditing {
                        // save
                        Task {
                            let success = await viewModel.updateLecture(oldLecture: tempLecture, newLecture: lecture)
                            if !success {
                                lecture = tempLecture
                            }
                        }
                        editMode = .inactive
                        resignFirstResponder()
                    } else {
                        // edit
                        tempLecture = lecture
                        editMode = .active
                        resignFirstResponder()
                    }
                } label: {
                    Text(editMode.isEditing ? "저장" : "편집")
                }

                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
    }
}

#if canImport(UIKit)
    extension View {
        func resignFirstResponder() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
#endif

// MARK: TODO - Move elsewhere if necessary

struct DetailLabel: View {
    let text: String
    var body: some View {
        VStack {
            Text(text)
                .padding(.horizontal, 5)
                .padding(.trailing, 10)
                .padding(.top, 2.5)
                .font(STFont.detailLabel)
                .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.8)))
                .frame(maxWidth: 70, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}

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

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        TextField("(없음)", value: $value, formatter: NumberFormatter())
            .disabled(!isEditing)
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
    @Environment(\.editMode) private var editMode

    @ViewBuilder private func timeTextLabel(from timePlace: TimePlace) -> some View {
        Text("\(timePlace.day.shortSymbol) \(timePlace.startTimeString) ~ \(timePlace.endTimeString)")
    }

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        Button {
            print("hi")
        } label: {
            timeTextLabel(from: timePlace)
                .font(.system(size: 16, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(!isEditing)
        .foregroundColor(Color(uiColor: .label))
    }
}

struct DetailButton: View {
    let text: String
    let action: () -> Void

    struct DetailButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .background(configuration.isPressed ? Color(uiColor: .opaqueSeparator) : STColor.groupForeground)
        }
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .padding()
        }
        .buttonStyle(DetailButtonStyle())
    }
}


struct LectureDetailList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LectureDetailScene(viewModel: .init(container: .preview), lecture: .preview)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
