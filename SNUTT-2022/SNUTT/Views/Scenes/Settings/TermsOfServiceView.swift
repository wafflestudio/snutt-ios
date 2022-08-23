//
//  TermsOfServiceView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        SingleWebView(request: URLRequest(url: SNUTTWebView.termsOfService.url))
            .navigationTitle("서비스 약관")
    }
}

struct TermsOfServiceScene_Previews: PreviewProvider {
    static var previews: some View {
        TermsOfServiceView()
    }
}
