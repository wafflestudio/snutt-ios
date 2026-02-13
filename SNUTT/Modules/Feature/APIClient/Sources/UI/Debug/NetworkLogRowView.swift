//
//  NetworkLogRowView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import SwiftUI

    struct NetworkLogRowView: View {
        let entry: NetworkLogEntry

        var body: some View {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    MethodBadge(method: entry.request.method, size: .small)

                    if let response = entry.response {
                        StatusBadge(statusCode: response.statusCode, size: .small)
                    } else if entry.error != nil {
                        ErrorBadge(size: .small)
                    } else {
                        PendingBadge(size: .small)
                    }

                    Spacer()

                    Text(entry.formattedDuration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(entry.request.url)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(formatDate(entry.timestamp))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }

        // MARK: - Helpers

        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss.SSS"
            return formatter.string(from: date)
        }
    }
#endif
