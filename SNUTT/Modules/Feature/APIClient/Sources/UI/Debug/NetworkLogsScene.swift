//
//  NetworkLogsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import SwiftUI

    public struct NetworkLogsScene: View {
        private let store = NetworkLogStore.shared
        @State private var searchText: String = ""

        private var filteredLogs: [NetworkLogEntry] {
            store.logs.filter { $0.matches(searchText: searchText) }
        }

        public init() {}

        public var body: some View {
            VStack {
                if filteredLogs.isEmpty {
                    emptyState
                } else {
                    logsList
                }
            }
            .navigationTitle("Network Logs")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search logs...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    clearButton
                }
            }
        }

        // MARK: - Views

        private var logsList: some View {
            List {
                Section {
                    ForEach(filteredLogs) { entry in
                        NavigationLink {
                            NetworkLogDetailView(entry: entry)
                        } label: {
                            NetworkLogRowView(entry: entry)
                        }
                    }
                } header: {
                    HStack {
                        Text("\(filteredLogs.count) log(s)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                }
            }
            .listStyle(.plain)
        }

        private var emptyState: some View {
            ContentUnavailableView {
                Label("No Logs", systemImage: "ladybug.slash")
            } description: {
                if searchText.isEmpty {
                    Text("Network requests will appear here")
                } else {
                    Text("No logs match '\(searchText)'")
                }
            }
        }

        private var clearButton: some View {
            Button {
                store.clearLogs()
                searchText = ""
            } label: {
                Label("Clear", systemImage: "trash")
                    .foregroundStyle(.red)
            }
            .disabled(store.logs.isEmpty)
        }
    }

    #Preview {
        NavigationStack {
            NetworkLogsScene()
                .navigationTitle("Network Logs")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
#endif
