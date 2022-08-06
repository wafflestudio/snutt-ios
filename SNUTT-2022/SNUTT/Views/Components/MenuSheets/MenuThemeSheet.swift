//
//  MenuThemeSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct MenuThemeSheet: View {
    @Binding var isOpen: Bool
    var selectedTheme: Theme
    
    var cancel: () -> Void
    var confirm: () async -> Void
    var select: (Theme) -> Void
    
    var body: some View {
        Sheet(isOpen: $isOpen, orientation: .bottom(maxHeight: 200), disableBackgroundTap: true, disableDragGesture: true) {
            VStack {
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
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
                
                Spacer()
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Theme.allCases, id: \.rawValue) { theme in
                            Button {
                                select(theme)
                            } label: {
                                VStack {
                                    Image(theme.imageName)
                                    Text(theme.name)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .font(STFont.detailLabel)
                                        .background(selectedTheme == theme ? Color(uiColor: .tertiarySystemFill) : .clear)
                                        .clipShape(Capsule())
                                }
                            }
                            .buttonStyle(.plain)

                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
    }
}

struct MenuThemeSheet_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray.ignoresSafeArea()
            MenuThemeSheet(isOpen: .constant(true), selectedTheme: .snutt, cancel: {}, confirm: {}, select: {_ in})
        }
    }
}
