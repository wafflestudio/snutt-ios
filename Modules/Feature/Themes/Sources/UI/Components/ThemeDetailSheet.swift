//
//  ThemeDetailSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Dependencies
import SharedUIComponents
import SwiftUI
import SwiftUIUtility
import ThemesInterface

struct ThemeDetailSheet: View {
    let theme: Theme

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeViewModel) private var themeViewModel: any ThemeViewModelProtocol
    @Dependency(\.appReviewService) private var appReviewService
    @State private var isEditDetailPresented = false

    var body: some View {
        GeometryReader { _ in
            VStack {
                DetailSheetButton(menu: theme.status == .customPrivate ? .edit : .detail) {
                    isEditDetailPresented = true
                }
                .sheet(isPresented: $isEditDetailPresented) {
                    NavigationStack {
                        ThemeEditDetailScene(entryTheme: theme)
                    }
                    .presentationDetents([.large])
                }

                DetailSheetButton(menu: .apply) {
                    dismiss()
                    errorAlertHandler.withAlert {
                        themeViewModel.selectTheme(theme)
                        try await themeViewModel.saveSelectedTheme()
                        await appReviewService.requestReviewIfNeeded()
                    }
                }

                if theme.status == .customPrivate {
                    DetailSheetButton(menu: .duplicate) {
                    }
                }

                if theme.status == .customPrivate || theme.status == .customDownloaded {
                    DetailSheetButton(menu: .delete) {
                    }
                }

                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .presentationDetents([.height(sheetHeight)])
        }
        .observeErrors()
    }

    private var sheetHeight: CGFloat {
        switch theme.status {
        case .customPrivate: 280
        case .customDownloaded: 225
        case .builtIn, .customPublished: 170
        }
    }
}

private struct DetailSheetButton: View {
    let menu: Menu
    let action: () -> Void

    var body: some View {
        AnimatableButton(
            animationOptions: .backgroundColor(touchDown: .label.opacity(0.05)).scale(0.99),
            layoutOptions: [.expandHorizontally, .respectIntrinsicHeight]
        ) {
            action()
        } configuration: { button in
            var config = UIButton.Configuration.plain()
            config.image = menu.image
            config.title = menu.text
            config.imagePadding = 10
            config.baseForegroundColor = .label
            button.contentHorizontalAlignment = .leading
            config.background.cornerRadius = 10
            return config
        }
    }
}

extension DetailSheetButton {
    enum Menu {
        case edit
        case detail
        case apply
        case duplicate
        case delete

        var image: UIImage? {
            nil
        }

        var text: String {
            switch self {
            case .edit: "상세 수정"
            case .detail: "상세 보기"
            case .apply: "현재 시간표에 적용"
            case .duplicate: "테마 복제"
            case .delete: "테마 삭제"
            }
        }
    }
}
