//
//  ThemeBottomSheet.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import SwiftUI

struct ThemeBottomSheet: View {
    @Binding var isOpen: Bool
    var isCustom: Bool?
    var isDefault: Bool?

    let openCustomThemeSheet: @MainActor () async -> Void
    let makeCustomThemeDefault: @MainActor () async -> Void
    let undoCustomThemeDefault: @MainActor () async -> Void
    let copyTheme: @MainActor () async -> Void
    let deleteTheme: @MainActor () async -> Void

    let openBasicThemeSheet: @MainActor () async -> Void
    let makeBasicThemeDefault: @MainActor () async -> Void
    let undoBasicThemeDefault: @MainActor () async -> Void

    @State private var isDeleteAlertPresented = false
    @State private var isUndeletableAlertPresented = false
    @State private var isUndoDefaultAlertPresented = false
    
    var body: some View {
        if let isCustom = isCustom, isCustom {
            Sheet(isOpen: $isOpen,
                  orientation: .bottom(maxHeight: 225),
                  disableBackgroundTap: false,
                  disableDragGesture: true)
            {
                VStack(spacing: 0) {
                    ThemeBottomSheetButton(menu: .edit, isSheetOpen: isOpen) {
                        Task {
                            await openCustomThemeSheet()
                        }
                    }

                    ThemeBottomSheetButton(menu: isDefault ?? false ? .unpin : .pin, isSheetOpen: isOpen) {
                        if let isDefault = isDefault, !isDefault {
                            Task {
                                await makeCustomThemeDefault()
                            }
                        } else {
                            isUndoDefaultAlertPresented = true
                        }
                    }

                    ThemeBottomSheetButton(menu: .copy, isSheetOpen: isOpen) {
                        Task {
                            await copyTheme()
                        }
                    }

                    ThemeBottomSheetButton(menu: .delete, isSheetOpen: isOpen) {
                        if let isDefault = isDefault, !isDefault {
                            isDeleteAlertPresented = true
                        } else {
                            isUndeletableAlertPresented = true
                        }
                    }
                    .alert("테마를 삭제하시겠습니까?\n이 테마가 지정된 시간표의 강의 색상은 유지됩니다.", isPresented: $isDeleteAlertPresented) {
                        Button("취소", role: .cancel, action: {})
                        Button("삭제", role: .destructive) {
                            Task {
                                await deleteTheme()
                            }
                        }
                    }
                    .alert("기본 테마는 삭제할 수 없습니다.", isPresented: $isUndeletableAlertPresented) {
                        Button("확인", role: .cancel, action: {})
                    }
                    .alert("기본 테마를 해제하시겠습니까?\n기본 테마는 SNUTT로 변경됩니다.", isPresented: $isUndoDefaultAlertPresented) {
                        Button("취소", role: .cancel, action: {})
                        Button("해제", role: .destructive) {
                            Task {
                                await undoCustomThemeDefault()
                            }
                        }
                    }
                }
            }
        } else {
            Sheet(isOpen: $isOpen,
                  orientation: .bottom(maxHeight: 125),
                  disableBackgroundTap: false,
                  disableDragGesture: true)
            {
                VStack(spacing: 0) {
                    ThemeBottomSheetButton(menu: .detail, isSheetOpen: isOpen) {
                        Task {
                            await openBasicThemeSheet()
                        }
                    }

                    ThemeBottomSheetButton(menu: isDefault ?? false ? .unpin : .pin, isSheetOpen: isOpen) {
                        Task {
                            if let isDefault = isDefault, !isDefault {
                                Task {
                                    await makeBasicThemeDefault()
                                }
                            } else {
                                isUndoDefaultAlertPresented = true
                            }
                        }
                    }
                    .alert("기본 테마를 해제하시겠습니까?\n기본 테마는 SNUTT로 변경됩니다.", isPresented: $isUndoDefaultAlertPresented) {
                        Button("취소", role: .cancel, action: {})
                        Button("해제", role: .destructive) {
                            Task {
                                await undoBasicThemeDefault()
                            }
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
        case edit
        case pin
        case unpin
        case copy
        case delete

        var imageName: String {
            switch self {
            case .detail: return "sheet.palette"
            case .edit: return "sheet.palette"
            case .pin: return "theme.pin.on"
            case .unpin: return "theme.pin.off"
            case .copy: return "menu.duplicate"
            case .delete: return "sheet.trash"
            }
        }

        var text: String {
            switch self {
            case .detail: return "상세 보기"
            case .edit: return "상세 수정"
            case .pin: return "기본 테마로 지정"
            case .unpin: return "기본 테마 해제"
            case .copy: return "테마 복제"
            case .delete: return "테마 삭제"
            }
        }
    }
}
