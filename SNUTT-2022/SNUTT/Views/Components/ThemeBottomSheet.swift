//
//  ThemeBottomSheet.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import SwiftUI

struct ThemeBottomSheet: View {
    @Binding var isOpen: Bool

    let targetTheme: Theme?
    let openBasicThemeSheet: @MainActor () async -> Void
    let openCustomThemeSheet: @MainActor () async -> Void
    let openDownloadedThemeSheet: @MainActor () async -> Void
    let applyThemeToTimetable: @MainActor () async -> Void
    let copyTheme: @MainActor () async -> Void
    let deleteTheme: @MainActor () async -> Void

    @State private var isApplyAlertPresented = false
    @State private var isDeleteAlertPresented = false

    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(
                  maxHeight: targetTheme?.isCustom == false ? 120 :
                             targetTheme?.status == .downloaded ? 170 : 220
              ),
              disableBackgroundTap: false,
              disableDragGesture: true)
        {
            VStack(spacing: 0) {
                if targetTheme?.isCustom == false {
                    ThemeBottomSheetButton(menu: .detail) {
                        Task {
                            await openBasicThemeSheet()
                        }
                    }
                    
                    ThemeBottomSheetButton(menu: .apply) {
                        isApplyAlertPresented = true
                    }
                } else if targetTheme?.status == .downloaded {
                    ThemeBottomSheetButton(menu: .detail) {
                        Task {
                            await openDownloadedThemeSheet()
                        }
                    }
                    
                    ThemeBottomSheetButton(menu: .apply) {
                        isApplyAlertPresented = true
                    }

                    ThemeBottomSheetButton(menu: .delete) {
                        isDeleteAlertPresented = true
                    }
                } else {
                    ThemeBottomSheetButton(menu: .edit) {
                        Task {
                            await openCustomThemeSheet()
                        }
                    }
                    
                    ThemeBottomSheetButton(menu: .apply) {
                        isApplyAlertPresented = true
                    }

                    ThemeBottomSheetButton(menu: .copy) {
                        Task {
                            await copyTheme()
                        }
                    }

                    ThemeBottomSheetButton(menu: .delete) {
                        isDeleteAlertPresented = true
                    }
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
            .alert("테마를 현재 시간표에 적용하시겠습니까?", isPresented: $isApplyAlertPresented) {
                Button("취소", role: .cancel, action: {})
                Button("적용") {
                    Task {
                        await applyThemeToTimetable()
                    }
                }
            }
        }
    }
}

struct ThemeBottomSheetButton: View {
    let menu: ThemeMenu
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
                    .font(STFont.regular14.font)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(10)
        }
        .buttonStyle(RectangleButtonStyle())
    }
}

extension ThemeBottomSheetButton {
    enum ThemeMenu {
        case detail
        case edit
        case apply
        case copy
        case delete

        var imageName: String {
            switch self {
            case .detail: return "sheet.palette"
            case .edit: return "sheet.palette"
            case .apply: return "sheet.palette"
            case .copy: return "menu.duplicate"
            case .delete: return "sheet.trash"
            }
        }

        var text: String {
            switch self {
            case .detail: return "상세 보기"
            case .edit: return "상세 수정"
            case .apply: return "현재 시간표에 적용"
            case .copy: return "테마 복제"
            case .delete: return "테마 삭제"
            }
        }
    }
}
