//
//  ThemeBottomSheet.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import SwiftUI

struct ThemeBottomSheet: View {
    @Binding var isOpen: Bool
    @State var theme: Theme
    
    let openCustomThemeSheet: @MainActor () async -> Void
    let makeCustomThemeDefault: @MainActor () async -> Void
    let undoCustomThemeDefault: @MainActor () async -> Void
    let copyTheme: @MainActor () async -> Void
    let deleteTheme: @MainActor () async -> Void
    
    let openBasicThemeSheet: @MainActor () async -> Void
    let makeBasicThemeDefault: @MainActor () async -> Void
   
    @State private var isDeleteAlertPresented = false

    var body: some View {
        Sheet(isOpen: $isOpen, orientation: .bottom(maxHeight: 225)) {
            switch (theme.isCustom) {
            case true:
                VStack(spacing: 0) {
                    ThemeBottomSheetButton(menu: .detail, isSheetOpen: isOpen) {
                        Task {
                            await openCustomThemeSheet()
                        }
                    }
                    
                    switch theme.isDefault {
                    case true:
                        ThemeBottomSheetButton(menu: .unpin, isSheetOpen: isOpen) {
                            Task {
                                await undoCustomThemeDefault()
                            }
                        }
                    case false:
                        ThemeBottomSheetButton(menu: .pin, isSheetOpen: isOpen) {
                            Task {
                                await makeCustomThemeDefault()
                            }
                        }
                    }
                    
                    ThemeBottomSheetButton(menu: .copy, isSheetOpen: isOpen) {
                        Task {
                            await copyTheme()
                        }
                    }

                    ThemeBottomSheetButton(menu: .delete, isSheetOpen: isOpen) {
                        isDeleteAlertPresented = true
                    }
                    .alert("테마를 삭제하시겠습니까?", isPresented: $isDeleteAlertPresented) {
                        Button("취소", role: .cancel, action: {})
                        Button("삭제", role: .destructive) {
                            Task {
                                await deleteTheme()
                            }
                        }
                    }
                }
                .transformEffect(.identity)
                
            case false:
                ThemeBottomSheetButton(menu: .detail, isSheetOpen: isOpen) {
                    Task {
                        await openBasicThemeSheet()
                    }
                }
                
                switch theme.isDefault {
                case true:
                    ThemeBottomSheetButton(menu: .unpin, isSheetOpen: isOpen) {
                        
                    }
                case false:
                    ThemeBottomSheetButton(menu: .pin, isSheetOpen: isOpen) {
                        Task {
                            await makeBasicThemeDefault()
                        }
                    }
                }
            }
        }
    }
}

struct ThemeBottomSheetButton: View {
    let menu: ThemeMenu
    var isSheetOpen: Bool = false

    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Image(menu.imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 12)

                Spacer().frame(width: 9)

                Text(menu.text)
                    .font(STFont.detailLabel)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
            .animation(.customSpring, value: isSheetOpen)
        }
        .buttonStyle(RectangleButtonStyle())
    }
}

extension ThemeBottomSheetButton {
    enum ThemeMenu {
        case detail
        case pin
        case unpin
        case copy
        case delete

        var imageName: String {
            switch self {
            case .detail: return "sheet.palette"
            case .pin: return "theme.pin.on"
            case .unpin: return "theme.pin.off"
            case .copy: return "menu.duplicate"
            case .delete: return "sheet.trash"
            }
        }

        var text: String {
            switch self {
            case .detail: return "상세 수정"
            case .pin: return "기본 테마로 지정"
            case .unpin: return "기본 테마 해제"
            case .copy: return "테마 복제"
            case .delete: return "테마 삭제"
            }
        }
    }
}
