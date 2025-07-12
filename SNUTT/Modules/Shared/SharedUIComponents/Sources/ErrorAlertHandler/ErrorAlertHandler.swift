//
//  ErrorAlertHandler.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

@Observable
@MainActor
public final class ErrorAlertHandler: Sendable {
    fileprivate var currentError: AnyLocalizedError?
    fileprivate var isErrorAlertPresented: Binding<Bool> {
        .init(
            get: {
                self.currentError != nil
            },
            set: { _ in
                self.currentError = nil
            }
        )
    }

    nonisolated init() {}

    public func withAlert<T: Sendable>(
        operation: @escaping () async throws -> T
    ) {
        Task {
            await withAlert {
                try await operation()
            }
        }
    }

    public func withAlert<T: Sendable>(
        operation: () async throws -> T
    ) async -> T? {
        do {
            return try await operation()
        } catch let error as any ErrorWrapper {
            currentError = .init(underlyingError: error.underlyingError)
            return nil
        } catch {
            currentError = .init(underlyingError: error)
            return nil
        }
    }

    public func withAlert<T: Sendable>(
        operation: () throws -> T
    ) -> T? {
        do {
            return try operation()
        } catch let error as any ErrorWrapper {
            currentError = .init(underlyingError: error.underlyingError)
            return nil
        } catch {
            currentError = .init(underlyingError: error)
            return nil
        }
    }
}

public protocol ErrorWrapper {
    var underlyingError: any Error { get }
}

private struct AnyLocalizedError: LocalizedError {
    let underlyingError: any Error
    var localizedError: (any LocalizedError)? {
        underlyingError as? any LocalizedError
    }

    var errorDescription: String? {
        localizedError?.errorDescription ?? SharedUIComponentsStrings.errorUnknownTitle
    }

    var failureReason: String? {
        localizedError?.failureReason
    }

    var recoverySuggestion: String? {
        localizedError?.recoverySuggestion
    }

    var errorMessage: String? {
        var messages = [
            failureReason,
            recoverySuggestion,
        ]
        .compactMap { $0 }
        #if DEBUG
            messages.append("[DEBUG] \(underlyingError)")
        #endif
        return if messages.isEmpty {
            nil
        } else {
            messages.joined(separator: " ")
        }
    }
}

extension View {
    public func observeErrors() -> some View {
        modifier(ErrorAlertModifier())
    }
}

private struct ErrorAlertModifier: ViewModifier {
    @State private var errorAlertHandler = ErrorAlertHandler()

    public func body(content: Content) -> some View {
        content
            .environment(\.errorAlertHandler, errorAlertHandler)
            .alert(isPresented: errorAlertHandler.isErrorAlertPresented, error: errorAlertHandler.currentError) { _ in
                Button(SharedUIComponentsStrings.errorDismiss, role: .cancel) {}
            } message: { error in
                Text(error.errorMessage ?? SharedUIComponentsStrings.errorUnknownMessage)
            }
    }
}

extension EnvironmentValues {
    @Entry public var errorAlertHandler: ErrorAlertHandler = .init()
}

// MARK: Preview

struct ErrorPreview: View {
    @Environment(\.errorAlertHandler) var errorHandler
    var body: some View {
        VStack {
            Button("Show Error") {
                errorHandler.withAlert {
                    throw PreviewError()
                }
            }
        }
    }
}

private struct PreviewError: LocalizedError {
    var errorDescription: String? {
        "errorDescription."
    }

    var failureReason: String? {
        "failureReason."
    }

    var recoverySuggestion: String? {
        "recoverSuggestion."
    }
}

#Preview {
    ErrorPreview()
        .observeErrors()
}
