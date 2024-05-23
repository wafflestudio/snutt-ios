//
//  Sheet.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import MemberwiseInit

public struct Sheet<Content>: View where Content: View {
    @Binding private var isPresented: Bool
    private let config: SheetConfiguration
    private var content: () -> Content
    private var orientation: SheetOrientation { config.orientation }

    @State private var backgroundOpacity: CGFloat = 0
    @State private var isOpen: Bool = false

    public init(
        isPresented: Binding<Bool>,
        configuration: SheetConfiguration,
        content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.config = configuration
        self.content = content
    }

    @State private var translation: CGFloat = 0

    public var body: some View {
        GeometryReader { reader in
            Color.black.opacity(0.3)
                .opacity(backgroundOpacity)
                .edgesIgnoringSafeArea(.all)
                .disabled(!isOpen)
                .onTapGesture {
                    if !config.disableBackgroundTap {
                        setIsOpen(false)
                    }
                }
            ZStack {
                config.sheetColor.opacity(config.sheetOpacity)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius, style: .continuous))
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    self.content()
                        .environment(\.sheetDismiss, SheetDismissAction(action: {
                            setIsOpen(false)
                        }))
                }
                .transformEffect(.identity)
            }
            .frame(width: orientation.getFrame(reader: reader).width, height: orientation.getFrame(reader: reader).height)
            .offset(orientation.getOffset(isOpen: isOpen, translation: translation, reader: reader))
            .animation(.defaultSpring, value: isOpen)
            .animation(.defaultSpring, value: translation == 0)
        }
        .sheetGesture($translation, dismiss: { setIsOpen(false) })
        .onAppear {
            setIsOpen(isPresented)
        }
    }

    private func setIsOpen(_ newValue: Bool) {
        isOpen = newValue
        withAnimation(.defaultSpring) {
            backgroundOpacity = newValue ? 1 : 0
        } completion: {
            if !newValue {
                isPresented = newValue
                config.onDismiss?()
            }
        }
    }
}

extension EnvironmentValues {
    @Entry public var sheetDismiss: SheetDismissAction = .init(action: nil)
}

@MainActor
public struct SheetDismissAction {
    let action: (@MainActor () -> Void)?
    public func callAsFunction() {
        action?()
    }
}

@MemberwiseInit(.public)
public struct SheetConfiguration {
    @Init(.public) let orientation: SheetOrientation
    @Init(.public) var cornerRadius: CGFloat = 20
    @Init(.public) var sheetColor: Color = .white
    @Init(.public) var sheetOpacity: CGFloat = 1
    @Init(.public) var disableBackgroundTap: Bool = false
    @Init(.public) var disableDragGesture: Bool = false
    @Init(.public) var onDismiss: (@MainActor () -> Void)? = nil
}

public enum SheetOrientation {
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
        case .left(let maxWidth):
            return value.translation.width > -maxWidth / 5
        case .bottom:
            return value.translation.height < 0
        }
    }

    func getIsOpen(from value: CGFloat) -> Bool {
        switch self {
        case .left(let maxWidth):
            return value > -maxWidth / 5
        case .bottom:
            return value < 0
        }
    }

    func getOpacity(from value: DragGesture.Value) -> CGFloat {
        let translation = getTranslation(from: value)
        switch self {
        case let .left(maxWidth):
            return translation > 0 ? 1 : 1.2 + translation / maxWidth
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
            return .init(width: 0, height: isOpen ? max(maxOffset + translation, maxOffset) : reader.size.height + 40)
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
