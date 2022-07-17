//
//  LectureDetailScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/24.
//

import Combine
import SwiftUI

struct LectureDetailScene: View {
    let viewModel: ViewModel
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
                                EditableDetailText(text: $lecture.title)
                            }
                            HStack {
                                DetailLabel(text: "교수")
                                EditableDetailText(text: $lecture.instructor)
                            }
                            if lecture.isCustom {
                                HStack {
                                    DetailLabel(text: "학점")
                                    EditableDetailNumber(text: $lecture.credit)
                                }
                                HStack {
                                    DetailLabel(text: "비고")
                                    EditableDetailText(text: $lecture.remark)
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
                                    EditableDetailText(text: $lecture.department)
                                }
                                HStack {
                                    DetailLabel(text: "학년")
                                    EditableDetailText(text: $lecture.academic_year)
                                }
                                HStack {
                                    DetailLabel(text: "학점")
                                    EditableDetailNumber(text: $lecture.credit)
                                }
                                HStack {
                                    DetailLabel(text: "분류")
                                    EditableDetailText(text: $lecture.classification)
                                }
                                HStack {
                                    DetailLabel(text: "구분")
                                    EditableDetailText(text: $lecture.category)
                                }
                                HStack {
                                    DetailLabel(text: "강좌번호")
                                    EditableDetailText(text: $lecture.course_number, preventEditing: true)
                                }
                                HStack {
                                    DetailLabel(text: "분반번호")
                                    EditableDetailText(text: $lecture.lecture_number, preventEditing: true)
                                }
                                HStack {
                                    DetailLabel(text: "비고")
                                    EditableDetailText(text: $lecture.remark, multiLine: true)
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
                                    EditableDetailTime(lecture: $lecture, timePlace: timePlace)
                                }
                                Spacer()
                                    .frame(height: 5)
                                HStack {
                                    DetailLabel(text: "장소")
                                    EditableDetailText(lecture: $lecture, timePlace: timePlace)
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
                .background(Color.white)
            }
            .padding(.vertical, 20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
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
                .font(STFont.detailLabel)
                .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.8)))
                .frame(maxWidth: 70, alignment: .leading)
        }
    }
}

struct EditableDetailText: View {
    @Binding var text: String
    @State var height: CGFloat = 0
    var preventEditing: Bool = false
    var multiLine: Bool = false
    @Environment(\.editMode) private var editMode
    
    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    var body: some View {
        Group {
            if multiLine {
                ZStack {
                    if text.isEmpty {
                        Text("(없음)")
                            .foregroundColor(preventEditing ? STColor.disabled : Color(uiColor: .placeholderText))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .disabled(true)
                    }
                    
                    UITextEditor(text: $text) { textView in
                        height = textView.contentSize.height
                    }
                    .frame(height: height)
                    .disabled(!isEditing || preventEditing)
                }
            } else {
                TextField("(없음)", text: $text)
                    .foregroundColor(preventEditing ? STColor.disabled : Color(uiColor: .label))
                    .disabled(!isEditing || preventEditing)
            }
        }
        .font(.system(size: 16, weight: .regular))
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
        .onDisappear {
            UITextView.appearance().backgroundColor = .none
            //                        UITextView.appearance().isScrollEnabled  = true
        }
    }
}


struct UITextEditor: UIViewRepresentable {
    @Binding var text: String
    let textDidChange: (UITextView) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        DispatchQueue.main.async {
            self.textDidChange(uiView)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text, textDidChange: textDidChange)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        let textDidChange: (UITextView) -> Void

        init(text: Binding<String>, textDidChange: @escaping (UITextView) -> Void) {
            self._text = text
            self.textDidChange = textDidChange
        }

        func textViewDidChange(_ textView: UITextView) {
            self.text = textView.text
            self.textDidChange(textView)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            textView.text = self.text
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            ensureCursorVisible(textView: textView)
        }
        
        private func findParentScrollView(of view: UIView) -> UIScrollView? {
                var current = view
                while let superview = current.superview {
                    if let scrollView = superview as? UIScrollView {
                        return scrollView
                    } else {
                        current = superview
                    }
                }
            return nil
        }
        private var cursorScrollPositionAnimator: UIViewPropertyAnimator?
        private func ensureCursorVisible(textView: UITextView) {
            guard let scrollView = findParentScrollView(of: textView),
                  let range = textView.selectedTextRange else {
                return
            }
            
            let cursorRect = textView.caretRect(for: range.start)
            var rectToMakeVisible = textView.convert(cursorRect, to: scrollView)
            
            rectToMakeVisible.origin.y -= cursorRect.height
            rectToMakeVisible.size.height *= 3
            
            if let existing = self.cursorScrollPositionAnimator {
                existing.stopAnimation(true)
            }
            
            let animator = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                scrollView.scrollRectToVisible(rectToMakeVisible, animated: false)
            }
            animator.startAnimation()
            self.cursorScrollPositionAnimator = animator
        }
    }
}

extension EditableDetailText {
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

struct EditableDetailNumber: View {
    @Binding var text: String
    @Environment(\.editMode) private var editMode
    
    init(text: Binding<Int>) {
        _text = Binding(get: {
            String(text.wrappedValue)
        }, set: {
            text.wrappedValue = Int($0) ?? 0
        })
    }
    
    var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }
    
    var body: some View {
        Group {
            TextField("(없음)", text: $text)
                .disabled(!isEditing)
                .keyboardType(.numberPad)
                .onReceive(Just(text)) { newValue in
                    let filtered = newValue.filter { "0123456789".contains($0) }
                    if filtered != newValue {
                        self.text = filtered
                    }
                }
        }
        .font(.system(size: 16, weight: .regular))
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct EditableDetailTime: View {
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
        Group {
            if isEditing {
                Button {
                    print("hi")
                } label: {
                    timeTextLabel(from: timePlace)
                }
            } else {
                timeTextLabel(from: timePlace)
            }
        }
        .font(.system(size: 16, weight: .regular))
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct DetailButton: View {
    let text: String
    let action: () -> Void
    
    struct DetailButtonStyle: ButtonStyle {
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity)
                .background(configuration.isPressed ? Color(uiColor: .opaqueSeparator) : Color(uiColor: .systemBackground))
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

extension LectureDetailScene {
    class ViewModel: BaseViewModel {}
}

struct LectureDetailList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LectureDetailScene(viewModel: .init(container: .preview), lecture: .preview)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
