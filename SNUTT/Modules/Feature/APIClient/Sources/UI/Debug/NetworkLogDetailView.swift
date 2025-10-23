//
//  NetworkLogDetailView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import SwiftUI

    struct NetworkLogDetailView: View {
        let entry: NetworkLogEntry

        var body: some View {
            List {
                // Overview Section
                Section("Overview") {
                    MethodRow(method: entry.request.method)
                    CopyableRow(label: "URL", value: entry.request.url)

                    if let response = entry.response {
                        StatusRow(statusCode: response.statusCode)
                    } else if let error = entry.error {
                        ErrorRow(error: error)
                    }

                    CopyableRow(label: "Duration", value: entry.formattedDuration)
                    CopyableRow(label: "Time", value: formatDate(entry.timestamp))
                }

                // Request Section
                Section("Request") {
                    if !entry.request.headers.isEmpty {
                        DisclosureGroup("Headers (\(entry.request.headers.count))") {
                            ForEach(Array(entry.request.headers.sorted(by: { $0.key < $1.key })), id: \.key) {
                                key,
                                value in
                                CopyableRow(label: key, value: value)
                            }
                        }
                    }

                    if let body = entry.request.body {
                        DisclosureGroup("Body") {
                            CopyableRow(label: "Content", value: body)
                        }
                    }
                }

                // Response Section
                if let response = entry.response {
                    Section("Response") {
                        if !response.headers.isEmpty {
                            DisclosureGroup("Headers (\(response.headers.count))") {
                                ForEach(Array(response.headers.sorted(by: { $0.key < $1.key })), id: \.key) {
                                    key,
                                    value in
                                    CopyableRow(label: key, value: value)
                                }
                            }
                        }

                        if let body = response.body {
                            DisclosureGroup("Body") {
                                CopyableRow(label: "Content", value: body)
                            }
                        }
                    }
                }

                // Error Section
                if let error = entry.error {
                    Section("Error") {
                        CopyableRow(label: "Message", value: error)
                    }
                }
            }
            .navigationTitle("Request Detail")
            .navigationBarTitleDisplayMode(.inline)
        }

        // MARK: - Helper Views

        private func formatDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            return formatter.string(from: date)
        }
    }

    // MARK: - Supporting Views

    private struct CopyableRow: View {
        let label: String
        let value: String
        var copyValue: String? = nil
        @State private var copied = false

        var body: some View {
            Button {
                UIPasteboard.general.string = copyValue ?? value
                copied = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        copied = false
                    }
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(value)
                            .font(.system(.callout, design: .monospaced))
                            .foregroundStyle(.primary)
                            .lineLimit(nil)
                            .truncationMode(.middle)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundStyle(copied ? .green : .secondary)
                        .font(.system(.caption))
                        .contentTransition(.symbolEffect(.replace))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private struct MethodRow: View {
        let method: String

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Method")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    MethodBadge(method: method, size: .medium)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private struct StatusRow: View {
        let statusCode: Int

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    StatusBadge(statusCode: statusCode, size: .medium)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private struct ErrorRow: View {
        let error: String

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Status")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ErrorBadge(size: .medium)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    #Preview {
        let sampleRequest = NetworkLogEntry.Request(
            method: "POST",
            url: "https://api.example.com/users",
            headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer token123",
                "User-Agent": "SNUTT/1.0",
            ],
            body: """
                {
                  "name": "John Doe",
                  "email": "john@example.com",
                  "age": 25
                }
                """
        )

        let sampleResponse = NetworkLogEntry.Response(
            statusCode: 200,
            headers: [
                "Content-Type": "application/json",
                "Date": "Mon, 19 Oct 2025 12:00:00 GMT",
                "Server": "nginx/1.20.0",
            ],
            body: """
                {
                  "id": "user_123",
                  "name": "John Doe",
                  "email": "john@example.com",
                  "created_at": "2025-10-19T12:00:00Z"
                }
                """
        )

        let sampleEntry = NetworkLogEntry(
            id: UUID(),
            timestamp: Date(),
            request: sampleRequest,
            response: sampleResponse,
            duration: 0.234,
            error: nil,
        )

        NavigationStack {
            NetworkLogDetailView(entry: sampleEntry)
        }
    }
#endif
