//
//  PrivacyPolicyView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        SingleWebView(request: URLRequest(url: WebViewType.privacyPolicy.url))
            .navigationTitle("개인정보처리방침")
    }
}

struct PrivacyPolicyScene_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
