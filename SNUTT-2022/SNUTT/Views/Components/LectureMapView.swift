//
//  LectureMapView.swift
//  SNUTT
//
//  Created by 최유림 on 2024/01/26.
//

import SwiftUI

struct LectureMapView: View {
    let buildings: [Location: String]

    @State private var showMapView: Bool = true
    @State private var isMapNotInstalledAlertPresented: Bool = false

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack(alignment: .topTrailing) {
            KakaoMapView(showMapView: $showMapView,
                         isMapNotInstalledAlertPresented: $isMapNotInstalledAlertPresented,
                         colorScheme: colorScheme,
                         buildings: buildings)
                .onAppear {
                    showMapView = true
                }.onDisappear {
                    showMapView = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            Image("map.beta")
        }
        .alert("실행 가능한 지도 어플리케이션이 없습니다.", isPresented: $isMapNotInstalledAlertPresented, actions: {})
    }
}
