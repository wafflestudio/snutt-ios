//
//  SyllabusWebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/10/11.
//

import SwiftUI
import SafariServices

struct SyllabusWebView: UIViewControllerRepresentable {
    @Binding var url: String
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: URL(string: url)!)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<Self>) {
        return
    }
}
