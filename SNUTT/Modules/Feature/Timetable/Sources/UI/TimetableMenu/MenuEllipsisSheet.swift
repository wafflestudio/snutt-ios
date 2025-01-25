//
//  MenuEllipsisSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

struct MenuEllipsisSheet: View {
    let viewModel: TimetableMenuViewModel

    @State private var isRenameMenuPresented = false

    var body: some View {
        GeometryReader { _ in
            VStack {
                EllipsisSheetButton(menu: .edit) {
                    isRenameMenuPresented = true
                }
                .sheet(isPresented: $isRenameMenuPresented) {
                    MenuRenameSheet(viewModel: viewModel)
                }

                EllipsisSheetButton(menu: .primary(isOn: false)) {}
                EllipsisSheetButton(menu: .theme) {}
                EllipsisSheetButton(menu: .delete) {}
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .presentationDetents([.height(225)])
            .presentationCornerRadius(15)
        }
    }
}

private struct EllipsisSheetButton: View {
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

extension EllipsisSheetButton {
    enum Menu {
        case edit
        case primary(isOn: Bool)
        case theme
        case delete

        var image: UIImage {
            switch self {
            case .edit: return TimetableAsset.sheetEdit.image
            case .primary(true): return TimetableAsset.sheetFriendOff.image
            case .primary(false): return TimetableAsset.sheetFriend.image
            case .theme: return TimetableAsset.sheetPalette.image
            case .delete: return TimetableAsset.sheetTrash.image
            }
        }

        var text: String {
            switch self {
            case .edit: return TimetableStrings.sheetEllipsisEditTitle
            case .primary(true): return TimetableStrings.sheetEllipsisPrimaryDisable
            case .primary(false): return TimetableStrings.sheetEllipsisPrimaryEnable
            case .theme: return TimetableStrings.sheetEllipsisTheme
            case .delete: return TimetableStrings.sheetEllipsisDelete
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    ZStack {
        Color.gray
        Button("Present") {
            isPresented = true
        }
        .buttonStyle(.borderedProminent)
    }
    .ignoresSafeArea()
    .sheet(isPresented: $isPresented) {
        MenuEllipsisSheet(viewModel: .init(timetableViewModel: .init()))
    }
}
