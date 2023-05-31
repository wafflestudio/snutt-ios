//
//  NetworkLogEntryView.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/05/09.
//

#if DEBUG
    import SwiftUI

    struct NetworkLogEntryView: View {
        let logEntry: NetworkLogEntry

        @State private var isExpanded = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    isExpanded.toggle()
                } label: {
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(logEntry.httpMethod ?? "UNK")")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))

                        Text("\(logEntry.url?.relativePath ?? "UNK")")
                            .lineLimit(isExpanded ? nil : 1)
                            .font(.system(size: 15, weight: .regular, design: .monospaced))

                        Spacer()
                        Text("\(logEntry.statusCode)")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(semanticColor)

                        Image("chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 11)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0), anchor: .init(x: 0.75, y: 0.5))
                            .padding(.trailing, 5)
                    }
                    .contentShape(Rectangle())
                    .padding(5)
                    .animation(.customSpring, value: isExpanded)
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(alignment: .leading) {
                        Group {
                            Text("Request")
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(Color.gray)
                            Text("\(logEntry.requestHeaders.description)")
                            if let requestDataString = logEntry.requestData?.jsonFormatted() {
                                Text("\n\(requestDataString)")
                            }

                            Divider().padding(.vertical, 2)

                            Text("Response")
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundColor(Color.gray)
                            Text("\(logEntry.responseHeaders.description)")
                            if let responseDataString = logEntry.responseData?.jsonFormatted() {
                                Text("\n\(responseDataString)")
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .padding(5)
                    .background(Color.gray.opacity(isExpanded ? 0.2 : 0))
                    .onTapGesture {
                        isExpanded.toggle()
                    }
                }

                Divider()
            }
            .animation(.customSpring, value: isExpanded)
        }

        var semanticColor: Color {
            if logEntry.statusCode >= 200 && logEntry.statusCode < 300 {
                return .green
            } else if logEntry.statusCode >= 300 && logEntry.statusCode < 400 {
                return .yellow
            } else if logEntry.statusCode >= 400 {
                return .red
            }
            return Color(uiColor: .label)
        }
    }

    struct NetworkLogEntryView_Previews: PreviewProvider {
        static var previews: some View {
            NetworkLogEntryView(logEntry: NetworkLogEntry.createFixture())
        }
    }
#endif