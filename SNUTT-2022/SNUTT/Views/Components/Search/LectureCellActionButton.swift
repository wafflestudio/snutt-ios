//
//  LectureCellActionButton.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/23.
//

import Foundation
import SwiftUI

enum IconType {
    case asset(name: String)
    case system(name: String)

    var image: Image {
        switch self {
        case let .asset(name):
            return Image(name)
        case let .system(name):
            return Image(systemName: name)
        }
    }
}

struct LectureCellActionButton: View {
    let icon: IconType
    let text: String
    let action: () async -> Void

    @State private var isLoading = false

    var body: some View {
        Button {
            isLoading = true
            Task {
                await action()
                isLoading = false
            }
        } label: {
            VStack {
                icon.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 19, height: 19)

                Text(text)
                    .font(.system(size: 11, weight: .regular))
            }
        }
        .frame(maxWidth: .infinity)
        .disabled(isLoading)
    }
}
