//
//  MenuThemeSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct MenuThemeSheet: View {
    @Binding var isOpen: Bool
    var selectedTheme: Theme

    var cancel: () async -> Void
    var confirm: () async -> Void
    var select: (Theme) async -> Void

    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(maxHeight: 200),
              disableDragGesture: true,
              onBackgroundTap: cancel) {
            VStack {
                MenuSheetTopBar(cancel: cancel, confirm: confirm, isSheetOpen: isOpen)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Theme.allCases, id: \.rawValue) { theme in
                            Button {
                                Task {
                                    await select(theme)
                                }
                            } label: {
                                VStack {
                                    Image(theme.imageName)
                                    Text(theme.name)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .font(STFont.detailLabel)
                                        .background(selectedTheme == theme ? Color(uiColor: .tertiarySystemFill) : .clear)
                                        .clipShape(Capsule())
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
    }
}

struct MenuThemeSheet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            MenuThemeSheet(isOpen: .constant(true), selectedTheme: .snutt, cancel: {}, confirm: {}, select: { _ in })
        }
    }
}
