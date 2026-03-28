//
//  LogoutButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct LogoutButton: View {
    let logoutAction: () async throws -> Void
    @State private var isLogoutAlertPresented = false
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        SettingsMenuButton(
            title: SettingsStrings.logout,
            onTap: { isLogoutAlertPresented = true },
            destructive: true
        )
        .alert(
            SettingsStrings.logoutAlert,
            isPresented: $isLogoutAlertPresented
        ) {
            Button(SettingsStrings.logout, role: .destructive) {
                errorAlertHandler.withAlert {
                    try await logoutAction()
                }
            }
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
        }
    }
}
