//
//  FilterSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/18.
//

import SwiftUI

struct FilterSheet<Content>: View where Content: View {
    let maxArea: CGFloat = 500

    @Binding var isOpen: Bool
    @ViewBuilder var content: () -> Content

    @GestureState private var translation: CGFloat = 0

    private var dragGesture: some Gesture {
        DragGesture().updating(self.$translation) { value, state, _ in
            state = value.translation.height
        }
        .onEnded { value in
            self.isOpen = value.translation.height < 0
        }
    }

    var body: some View {
        GeometryReader { reader in
            ZStack {
                Color(UIColor.systemBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            isOpen.toggle()
                        } label: {
                            Image("xmark")
                        }
                    }
                    .padding(20)
                    Spacer()
                    self.content()
                    Spacer()
                }
            }
            .frame(width: reader.size.width, height: maxArea)
            .offset(y: isOpen ? max(reader.size.height - maxArea + translation, reader.size.height - maxArea) : reader.size.height)
            .animation(.customSpring, value: isOpen)
        }
        .edgesIgnoringSafeArea(.bottom)
        .highPriorityGesture(
            dragGesture
        )
    }
}

/// A simple wrapper that is used to preview `Filter`.
struct FilterSheetWrapper: View {
    class isOpenObject: ObservableObject {
        @Published var value = false
    }

    @StateObject var isOpen = isOpenObject()
    var body: some View {
        ZStack {
            Button {
                isOpen.value.toggle()
            } label: {
                Text("버튼을 탭하세요.")
            }

            FilterSheet(isOpen: $isOpen.value) {
                Text("helllllo")
            }
        }
    }
}

struct FilterSheetWrapper_Previews: PreviewProvider {
    static var previews: some View {
        FilterSheetWrapper()
    }
}
