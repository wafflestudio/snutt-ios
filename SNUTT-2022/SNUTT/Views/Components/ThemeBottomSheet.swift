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
    let openCustomThemeSheet: @MainActor () async -> Void
    let openDownloadedThemeSheet: @MainActor () async -> Void
    let copyTheme: @MainActor () async -> Void
    let deleteTheme: @MainActor () async -> Void

    @State private var isDeleteAlertPresented = false

    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(
                  maxHeight: targetTheme?.status == .downloaded ? 120 : 170
              ),
              disableBackgroundTap: false,
              disableDragGesture: true)
        {
            VStack(spacing: 0) {
                if targetTheme?.status == .downloaded {
                    ThemeBottomSheetButton(menu: .detail) {
                        Task {
                            await openDownloadedThemeSheet()
                        }
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
        case copy
        case delete

        var imageName: String {
            switch self {
            case .detail: return "sheet.palette"
            case .edit: return "sheet.palette"
            case .copy: return "menu.duplicate"
            case .delete: return "sheet.trash"
            }
        }

        var text: String {
            switch self {
            case .detail: return "상세 보기"
            case .edit: return "상세 수정"
            case .copy: return "테마 복제"
            case .delete: return "테마 삭제"
            }
        }
    }
}
