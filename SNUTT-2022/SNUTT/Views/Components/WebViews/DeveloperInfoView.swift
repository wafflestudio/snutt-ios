//
//  DeveloperInfoView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct DeveloperInfoView: View {
    var body: some View {
        SingleWebView(url: WebViewType.developerInfo.url)
            .navigationTitle("개발자 정보")
            .analyticsScreen(.settingsDevelopers)
    }
}

struct DeveloperInfoScene_Previews: PreviewProvider {
    static var previews: some View {
        DeveloperInfoView()
    }
}
