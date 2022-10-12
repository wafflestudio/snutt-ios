//
//  SyllabusWebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/10/11.
//

import SafariServices
import SwiftUI

struct SyllabusWebView: UIViewControllerRepresentable {
    @Binding var url: String

    func makeUIViewController(context _: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: URL(string: url)!)
    }

    func updateUIViewController(_: SFSafariViewController, context _: UIViewControllerRepresentableContext<Self>) {}
}
