//
//  Sheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/06.
//

import SwiftUI

struct Sheet<Content>: View where Content: View {
    @Binding var isOpen: Bool
    let orientation: SheetOrientation
    var cornerRadius: CGFloat = 20
    @ViewBuilder var content: () -> Content

    @GestureState private var translation: CGFloat = 0
    @State private var backgroundOpacity: CGFloat = 0

    private var dragGesture: some Gesture {
        DragGesture().updating(self.$translation) { value, state, _ in
            state = orientation.getTranslation(from: value)
        }
        .onChanged { value in
            backgroundOpacity = orientation.getOpacity(from: value)
        }
        .onEnded { value in
            self.isOpen = orientation.getIsOpen(from: value)
        }
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
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    .edgesIgnoringSafeArea(.all)
                self.content()
            }
            .frame(width: orientation.getFrame(reader: reader).width, height: orientation.getFrame(reader: reader).height)
            .offset(orientation.getOffset(isOpen: isOpen, translation: translation, reader: reader))
            .animation(.customSpring, value: isOpen)
        }
        .ignoresSafeArea()
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

enum SheetOrientation {
    case left(maxWidth: CGFloat)
    case bottom(maxHeight: CGFloat)

    func getTranslation(from value: DragGesture.Value) -> CGFloat {
        switch self {
        case .left:
            return value.translation.width
        case .bottom:
            return value.translation.height
        }
    }

    func getIsOpen(from value: DragGesture.Value) -> Bool {
        switch self {
        case .left:
            return value.translation.width > 0
        case .bottom:
            return value.translation.height < 0
        }
    }

    func getOpacity(from value: DragGesture.Value) -> CGFloat {
        let translation = getTranslation(from: value)
        switch self {
        case let .left(maxWidth):
            return translation > 0 ? 1 : 1 + translation / maxWidth
        case let .bottom(maxHeight):
            return translation < 0 ? 1 : 1 - translation / maxHeight
        }
    }

    func getOffset(isOpen: Bool, translation: CGFloat, reader: GeometryProxy) -> CGSize {
        switch self {
        case let .left(maxWidth):
            return .init(width: min(-(isOpen ? 0 : maxWidth) + translation, 0), height: 0)
        case let .bottom(maxHeight):
            let maxOffset = reader.size.height - maxHeight
            return .init(width: 0, height: isOpen ? max(maxOffset + translation, maxOffset) : reader.size.height + 10)
        }
    }

    func getFrame(reader: GeometryProxy) -> (width: CGFloat, height: CGFloat) {
        switch self {
        case let .left(maxWidth):
            return (width: maxWidth, height: reader.size.height)
        case let .bottom(maxHeight):
            return (width: reader.size.width, height: maxHeight)
        }
    }
}

// struct Sheet_Previews: PreviewProvider {
//    static var previews: some View {
//        Sheet()
//    }
// }
