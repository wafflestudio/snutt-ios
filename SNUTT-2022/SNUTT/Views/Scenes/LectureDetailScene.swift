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
    @State private var isDeleteAlertPresented = false

    // for modal presentation
    var isPresentedModally: Bool = false
    @Environment(\.dismiss) var dismiss

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

                            HStack {
                                DetailLabel(text: "색")
                                NavigationLink {
                                    LectureColorList(theme: lecture.theme ?? .snutt, colorIndex: $lecture.colorIndex, customColor: $lecture.color)
                                } label: {
                                    HStack {
                                        LectureColorPreview(lectureColor: lecture.getColor())
                                            .frame(height: 25)
                                        Spacer()
                                        if editMode.isEditing {
                                            Image("chevron.right")
                                        }
                                    }
                                }
                                .disabled(!editMode.isEditing)
                            }
                            .animation(.customSpring, value: editMode.isEditing)
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
                                    DetailLabel(text: "정원")
                                    EditableNumberField(value: $lecture.quota, readOnly: true)
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
                    
                    if !editMode.isEditing {
                        DetailButton(text: "강의계획서") {
                            
                        }
                        
                        DetailButton(text: "강의평") {
                            Task {
                                await viewModel.fetchReviewId(of: lecture)
                            }
                        }
                    }

                    if !isPresentedModally {
                        DetailButton(text: "삭제", role: .destructive) {
                            isDeleteAlertPresented = true
                        }
                        .alert("강의를 삭제하시겠습니까?", isPresented: $isDeleteAlertPresented) {
                            Button("취소", role: .cancel, action: {})
                            Button("삭제", role: .destructive) {
                                Task {
                                    await viewModel.deleteLecture(lecture: lecture)
                                }
                            }
                        }
                    }
                }
                .background(STColor.groupForeground)
            }
            .animation(.customSpring, value: editMode.isEditing)
            .padding(.vertical, 20)
        }
        .background(STColor.groupBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode.isEditing)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if isPresentedModally {
                    Button {
                        dismiss()
                    } label: {
                        Text("취소")
                            .foregroundColor(Color(uiColor: .label))
                    }
                } else if editMode.isEditing {
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
                if !isPresentedModally {
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
                }
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
    @Environment(\.editMode) private var editMode

    @ViewBuilder private func timeTextLabel(from timePlace: TimePlace) -> some View {
        Text("\(timePlace.day.shortSymbol) \(timePlace.startTimeString) ~ \(timePlace.endTimeString)")
    }

    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    var body: some View {
        Button {
        } label: {
            timeTextLabel(from: timePlace)
                .font(.system(size: 16, weight: .regular))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(!isEditing)
        .foregroundColor(Color(uiColor: .label))
    }
}

struct RectangleButtonStyle: ButtonStyle {
    var color: Color? = nil
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .contentShape(Rectangle())
            .background(configuration.isPressed ? STColor.buttonPressed : (color ?? .clear))
    }
}

struct DetailButton: View {
    let text: String
    let role: ButtonRole?
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(text)
                .frame(maxWidth: .infinity)
                .padding()
                .contentShape(Rectangle())
                .foregroundColor(role == .destructive ? .red : Color(uiColor: .label))
        }
        .buttonStyle(RectangleButtonStyle(color: STColor.groupForeground))
    }
}

extension DetailButton {
    init(text: String, action: @escaping () -> Void) {
        self.text = text
        role = nil
        self.action = action
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
