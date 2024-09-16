//
//  ThemeMarketView.swift
//  SNUTT
//
//  Created by 이채민 on 9/16/24.
//

import SwiftUI

struct ThemeMarketView: View {
    var body: some View {
        SingleWebView(url: WebViewType.themeMarket.url)
            .navigationTitle("테마 마켓")
    }
}

struct ThemeMarketScene_Previews: PreviewProvider {
    static var previews: some View {
        ThemeMarketView()
    }
}
