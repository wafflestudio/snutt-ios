//
//  MenuEllipsisSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import LinkPresentation
import SwiftUI

struct MenuEllipsisSheet: View {
    @Binding var isOpen: Bool
    var isPrimary: Bool?
    @Binding var targetTimetable: Timetable?
    let timetableConfig: TimetableConfiguration
    let openRenameSheet: @MainActor () -> Void
    let setPrimaryTimetable: @MainActor () async -> Void
    let unsetPrimaryTimetable: @MainActor () async -> Void
    let openThemeSheet: @MainActor () -> Void
    let deleteTimetable: @MainActor () async -> Void
    @State private var isDeleteAlertPresented = false
    @State private var screenshotData: Data?
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Sheet(isOpen: $isOpen, orientation: .bottom(maxHeight: 260)) {
            VStack(spacing: 0) {
                EllipsisSheetButton(menu: .edit, isSheetOpen: isOpen) {
                    openRenameSheet()
                }

                if let isPrimary = isPrimary {
                    EllipsisSheetButton(menu: .primary(isOn: isPrimary)) {
                        Task {
                            isPrimary
                                ? await unsetPrimaryTimetable()
                                : await setPrimaryTimetable()
                        }
                    }
                }
                
                EllipsisSheetButton(menu: .share) {
                    if let targetTimetable = targetTimetable {
                        screenshotData = createTimetableImage(
                            timetable: targetTimetable,
                            timetableConfig: timetableConfig,
                            preferredColorScheme: colorScheme
                        )
                    }
                }

                EllipsisSheetButton(menu: .theme, isSheetOpen: isOpen) {
                    openThemeSheet()
                }

                EllipsisSheetButton(menu: .delete, isSheetOpen: isOpen) {
                    isDeleteAlertPresented = true
                }
                .alert("시간표를 삭제하시겠습니까?", isPresented: $isDeleteAlertPresented) {
                    Button("취소", role: .cancel, action: {})
                    Button("삭제", role: .destructive) {
                        Task {
                            await deleteTimetable()
                        }
                    }
                }
            }
            .transformEffect(.identity)
        }
        .sheet(isPresented: .init(
            get: { screenshotData != nil },
            set: { _ in screenshotData = nil }
        )) {
            if let screenshotData = screenshotData {
                /// Provide title for `UIActivityViewController`.
                let linkMetadata = LinkMetadata()
                ActivityViewController(activityItems: [screenshotData, linkMetadata])
                    .analyticsScreen(.timetableShare)
            }
        }
    }
}

// MARK: ActivityViewController

private struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context _: UIViewControllerRepresentableContext<ActivityViewController>)
        -> UIActivityViewController
    {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(
        _: UIActivityViewController,
        context _: UIViewControllerRepresentableContext<ActivityViewController>
    ) {}
}

final private class LinkMetadata: NSObject, UIActivityItemSource {
    let linkMetadata: LPLinkMetadata

    override init() {
        linkMetadata = LPLinkMetadata()
        linkMetadata.title = "SNUTT"
        super.init()
    }

    func activityViewControllerPlaceholderItem(_: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_: UIActivityViewController, itemForActivityType _: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    func activityViewControllerLinkMetadata(_: UIActivityViewController) -> LPLinkMetadata? {
        return linkMetadata
    }
}
