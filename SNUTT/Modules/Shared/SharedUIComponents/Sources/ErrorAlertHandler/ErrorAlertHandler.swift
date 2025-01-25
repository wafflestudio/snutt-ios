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
        .init(get: {
            self.currentError != nil
        }, set: { _ in
            self.currentError = nil
        })
    }

    nonisolated init() {}

    public func withAlert<T: Sendable>(
        operation: () async throws -> T
    ) async -> T? {
        do {
            return try await operation()
        } catch {
            currentError = .init(wrappedError: error)
            return nil
        }
    }

    public func withAlert<T: Sendable>(
        operation: () throws -> T
    ) -> T? {
        do {
            return try operation()
        } catch {
            currentError = .init(wrappedError: error)
            return nil
        }
    }
}

private struct AnyLocalizedError: LocalizedError {
    let wrappedError: any Error
    var localizedError: (any LocalizedError)? {
        wrappedError as? any LocalizedError
    }

    var errorDescription: String? {
        localizedError?.errorDescription ?? wrappedError.localizedDescription
    }

    var failureReason: String? {
        localizedError?.failureReason
    }

    var recoverySuggestion: String? {
        localizedError?.recoverySuggestion
    }
}

public extension View {
    func observeErrors() -> some View {
        modifier(ErrorAlertModifier())
    }
}

private struct ErrorAlertModifier: ViewModifier {
    @State private var errorAlertHandler = ErrorAlertHandler()

    public func body(content: Content) -> some View {
        content
            .environment(\.errorAlertHandler, errorAlertHandler)
            .alert(isPresented: errorAlertHandler.isErrorAlertPresented, error: errorAlertHandler.currentError) {
                Button("확인", role: .cancel) {}
            }
    }
}

public extension EnvironmentValues {
    @Entry var errorAlertHandler: ErrorAlertHandler = .init()
}
