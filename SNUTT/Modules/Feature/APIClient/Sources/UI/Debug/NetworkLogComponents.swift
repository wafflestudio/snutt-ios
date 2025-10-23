//
//  NetworkLogComponents.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

#if DEBUG
    import SwiftUI

    // MARK: - Badges

    struct MethodBadge: View {
        let method: String
        let size: BadgeSize

        var body: some View {
            Text(method)
                .font(.system(size.fontSize, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
        }
    }

    struct StatusBadge: View {
        let statusCode: Int
        let size: BadgeSize

        var body: some View {
            Text("\(statusCode)")
                .font(.system(size.fontSize, design: .monospaced))
                .fontWeight(.medium)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
                .background(statusColor(statusCode).opacity(0.2))
                .foregroundStyle(statusColor(statusCode))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }

        private func statusColor(_ statusCode: Int) -> Color {
            switch statusCode {
            case 200..<300: return .green
            case 300..<400: return .blue
            case 400..<500: return .orange
            case 500..<600: return .red
            default: return .gray
            }
        }
    }

    struct ErrorBadge: View {
        let size: BadgeSize

        var body: some View {
            Text("ERROR")
                .font(.system(size.fontSize, design: .monospaced))
                .fontWeight(.medium)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
                .background(Color.red.opacity(0.2))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    struct PendingBadge: View {
        let size: BadgeSize

        var body: some View {
            Text("PENDING")
                .font(.system(size.fontSize, design: .monospaced))
                .fontWeight(.medium)
                .padding(.horizontal, size.horizontalPadding)
                .padding(.vertical, size.verticalPadding)
                .background(Color.gray.opacity(0.2))
                .foregroundStyle(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    // MARK: - Badge Size

    enum BadgeSize {
        case small
        case medium

        var fontSize: Font.TextStyle {
            switch self {
            case .small: return .caption
            case .medium: return .callout
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: return 6
            case .medium: return 6
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 2
            }
        }
    }
#endif
