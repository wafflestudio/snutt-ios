//
//  MenuSheetTopBar.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/21.
//

import SwiftUI

struct MenuSheetTopBar: View {
    var cancel: () -> Void
    var confirm: () async -> Void
    var confirmDisabled: Bool = false
    
    var body: some View {
        HStack {
            Button {
                cancel()
            } label: {
                Text("취소")
            }

            Spacer()

            Button {
                Task {
                    await confirm()
                }
            } label: {
                Text("적용")
            }
            .disabled(confirmDisabled)
        }
        .padding(.vertical)

        Spacer()
            .frame(maxHeight: 20)
    }
}

