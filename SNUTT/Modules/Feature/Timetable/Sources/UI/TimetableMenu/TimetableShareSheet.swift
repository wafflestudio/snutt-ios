//
//  TimetableShareSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import LinkPresentation
import SwiftUI
import UIKit

struct TimetableShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    init(timetableImage: TimetableImage) {
        activityItems = [timetableImage.data, LinkMetadata()]
    }

    func makeUIViewController(
        context _: UIViewControllerRepresentableContext<TimetableShareSheet>
    )
        -> UIActivityViewController
    {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(
        _: UIActivityViewController,
        context _: UIViewControllerRepresentableContext<TimetableShareSheet>
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
