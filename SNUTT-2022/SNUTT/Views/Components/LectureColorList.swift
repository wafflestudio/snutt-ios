//
//  LectureColorList.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/29.
//

import SwiftUI

struct LectureColorList: View {
    var theme: Theme

    /// `colorIndex`의 값이 `0`이면 `customColor`를 사용하고, 그렇지 않으면 `colorList[colorIndex]`를 사용한다.
    @Binding var colorIndex: Int
    @Binding var customColor: LectureColor?

    @Binding private var selectionFg: Color
    @Binding private var selectionBg: Color

    init(theme: Theme, colorIndex: Binding<Int>, customColor: Binding<LectureColor?>) {
        self.theme = theme
        _colorIndex = colorIndex
        _customColor = customColor
        _selectionBg = .init(get: {
            customColor.wrappedValue?.bg ?? LectureColor.temporary.bg
        }, set: { color in
            customColor.wrappedValue = .init(fg: customColor.wrappedValue?.fg ?? LectureColor.temporary.fg, bg: color)
        })
        _selectionFg = .init(get: {
            customColor.wrappedValue?.fg ?? LectureColor.temporary.fg
        }, set: { color in
            customColor.wrappedValue = .init(fg: color, bg: customColor.wrappedValue?.bg ?? LectureColor.temporary.bg)
        })
    }

    private var colorList: [LectureColor] {
        theme.getLectureColorList()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(colorList.indices.dropFirst(1), id: \.self) { index in
                    makePickerButton(lectureColor: colorList[index],
                                     displayTick: index == colorIndex,
                                     title: "\(theme.name) \(index)") {
                        colorIndex = index
                    }

                    Divider()
                        .frame(height: 1)
                        .padding(.leading, 20)
                }

                VStack(spacing: 0) {
                    makePickerButton(lectureColor: customColor ?? .temporary,
                                     displayTick: colorIndex == 0,
                                     title: "직접 선택하기") {
                        colorIndex = 0
                    }

                    if colorIndex == 0 {
                        Divider()
                            .frame(height: 1)
                        VStack {
                            Group {
                                ColorPicker("글꼴색", selection: $selectionFg, supportsOpacity: false)
                                ColorPicker("배경색", selection: $selectionBg, supportsOpacity: false)
                            }
                        }
                        .padding(.leading, 80)
                        .padding(.trailing, 20)
                        .padding(.vertical, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
            }
            .background(STColor.groupForeground)
            .border(Color.black.opacity(0.1), width: 0.5)
            .padding(.vertical, 20)
        }
        .animation(.customSpring, value: colorIndex)
        .background(STColor.groupBackground)
        .navigationTitle("색상 선택")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func makePickerButton(lectureColor: LectureColor, displayTick: Bool, title: String, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.customSpring) {
                action()
            }
        } label: {
            HStack(alignment: .center) {
                LectureColorPreview(lectureColor: lectureColor)
                    .frame(height: 25)

                Text(title)
                    .font(.system(size: 16))
                    .padding(.leading, 10)

                Spacer()

                if displayTick {
                    Image(systemName: "checkmark")
                }
            }
            .animation(nil, value: colorIndex)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .buttonStyle(RectangleButtonStyle(color: STColor.groupForeground))
    }
}

#if DEBUG
struct LectureColorList_Previews: PreviewProvider {
    struct Wrapper: View {
        @State var lecture: Lecture = .preview
        var body: some View {
            NavigationView {
                LectureColorList(theme: lecture.theme ?? .snutt, colorIndex: $lecture.colorIndex, customColor: $lecture.color)
            }
        }
    }

    static var previews: some View {
        Wrapper()
    }
}
#endif
