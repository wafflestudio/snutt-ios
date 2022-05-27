//
//  MenuSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/05/23.
//

import SwiftUI

struct MenuSheet<Content>: View where Content: View {
    let maxWidth: CGFloat = 290

    @Binding var isOpen: Bool
    @ViewBuilder var content: () -> Content

    @GestureState private var translation: CGFloat = 0
    @State private var backgroundOpacity: CGFloat = 0

    private var dragGesture: some Gesture {
        DragGesture().updating(self.$translation) { value, state, _ in
            state = value.translation.width
        }
        .onChanged { value in
            let translation = value.translation.width
            let percent = translation > 0 ? 1 : 1 + translation / maxWidth
            backgroundOpacity = percent
        }
        .onEnded { value in
            self.isOpen = value.translation.width > 0
        }
    }

    private var offset: CGFloat {
        isOpen ? 0 : maxWidth
    }

    var body: some View {
        GeometryReader { reader in
            Color.black.opacity(0.3)
                .opacity(backgroundOpacity)
                .edgesIgnoringSafeArea(.all)
                .disabled(!isOpen)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isOpen = false
                    }
                }

            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                self.content()
            }
            .frame(width: maxWidth, height: reader.size.height)
            .offset(x: min(-self.offset + self.translation, 0))
            .animation(.customSpring, value: isOpen)
        }
        .highPriorityGesture(
            dragGesture
        )
        .onChange(of: isOpen, perform: { newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                backgroundOpacity = newValue ? 1 : 0
            }
        })
    }
}

extension Animation {
    static var customSpring: Animation {
        spring(response: 0.2, dampingFraction: 1, blendDuration: 0)
    }
}

/// A simple wrapper that is used to preview `MenuSheet`.
struct MenuSheetWrapper: View {
    @State var isOpen = false
    var body: some View {
        ZStack {
            Button {
                isOpen = !isOpen
            } label: {
                Text("버튼을 탭하세요.")
            }

            MenuSheet(isOpen: $isOpen) {
                Text("This is dummy content.")
            }
        }
    }
}

struct MenuSheetWrapper_Previews: PreviewProvider {
    static var previews: some View {
        MenuSheetWrapper()
    }
}
