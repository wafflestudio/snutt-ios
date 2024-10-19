//
//  SyllabusFilePreviewController.swift
//  SNUTT
//
//  Created by 박신홍 on 10/19/24.
//

import QuickLook

final class SyllabusFilePreviewController: QLPreviewController {
    private let item: any QLPreviewItem
    init(item: any QLPreviewItem) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SyllabusFilePreviewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> any QLPreviewItem {
        item
    }
}
