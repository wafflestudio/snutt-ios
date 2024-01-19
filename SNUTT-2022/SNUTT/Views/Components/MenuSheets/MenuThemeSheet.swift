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
    var themes: [Theme]

    var cancel: @MainActor () -> Void
    var confirm: @MainActor () async -> Void
    var select: @MainActor (Theme) -> Void
    var newTheme: @MainActor () -> Void
    
    @State private var pushToNewThemeScene = false

    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(maxHeight: 200),
              disableDragGesture: true,
              onBackgroundTap: cancel)
        {
            VStack {
                MenuSheetTopBar(cancel: cancel, confirm: confirm, isSheetOpen: isOpen)
                    .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        VStack {
                            Button {
                                newTheme()
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .fill(STColor.gray)
                                        .frame(width: 80, height: 78)
                                        .cornerRadius(6)
                                    Image("nav.plus")
                                }
                            }
                            Text("새 테마")
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .font(STFont.detailLabel)
                        }
                        
                        ForEach(themes, id: \.id) { theme in
                            Button {
                                select(theme)
                            } label: {
                                VStack {
                                    if (theme.isCustom) {
                                        ThemeIcon(theme: theme)
                                    } else {
                                        Image(theme.theme?.imageName ?? "")
                                    }
                                    Text(theme.name)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .font(STFont.detailLabel)
                                        .background(selectedTheme.id == theme.id ? Color(uiColor: .tertiarySystemFill) : .clear)
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
