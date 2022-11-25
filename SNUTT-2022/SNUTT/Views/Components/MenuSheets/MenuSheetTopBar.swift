//
//  MenuSheetTopBar.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/21.
//

import SwiftUI

struct MenuSheetTopBar: View {
    var cancel: () async -> Void
    var confirm: () async -> Void
    var confirmDisabled: Bool = false

    /// An optional property used to fix animation glitch in iOS 16. See this [Pull Request](https://github.com/wafflestudio/snutt-ios/pull/132).
    var isSheetOpen: Bool = false

    var body: some View {
        HStack {
            Button {
                Task {
                    await cancel()
                }
            } label: {
                Text("취소")
                    .animation(.customSpring, value: isSheetOpen)
            }

            Spacer()

            Button {
                Task {
                    await confirm()
                }
            } label: {
                Text("적용")
                    .animation(.customSpring, value: isSheetOpen)
            }
            .disabled(confirmDisabled)
        }
        .padding(.vertical)

        Spacer()
            .frame(maxHeight: 20)
    }
}
