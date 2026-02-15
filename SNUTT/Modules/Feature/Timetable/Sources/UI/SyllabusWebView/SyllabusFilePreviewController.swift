//
//  SyllabusFilePreviewController.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import QuickLook

final class SyllabusFilePreviewController: QLPreviewController {
    private let item: any QLPreviewItem
    init(item: any QLPreviewItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        dataSource = self
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SyllabusFilePreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        1
    }

    func previewController(_: QLPreviewController, previewItemAt _: Int) -> any QLPreviewItem {
        item
    }
}
