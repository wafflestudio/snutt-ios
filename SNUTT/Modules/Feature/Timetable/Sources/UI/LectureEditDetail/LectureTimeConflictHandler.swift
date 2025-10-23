//
//  LectureTimeConflictHandler.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import SharedUIComponents
import SwiftUI

@Observable
@MainActor
public final class LectureTimeConflictHandler: Sendable {
    fileprivate var pendingOperation: ConflictOperation?
    fileprivate var isConflictAlertPresented: Binding<Bool> {
        .init(
            get: {
                self.pendingOperation != nil
            },
            set: { _ in
                self.pendingOperation = nil
            }
        )
    }

    nonisolated init() {}

    @discardableResult public func withConflictHandling<T: Sendable>(
        operation: @escaping (_ overrideOnConflict: Bool) async throws -> T
    ) async throws -> T? {
        do {
            return try await operation(false)
        } catch let error as any APIClientError {
            if let serverError = error.serverError, serverError.isLectureConflictError {
                return await handleConflictError(operation: operation, error: serverError)
            } else {
                throw error
            }
        } catch {
            // conflict가 아닌 다른 에러는 다시 throw
            throw error
        }
    }

    private func handleConflictError<T: Sendable>(
        operation: @escaping (_ overrideOnConflict: Bool) async throws -> T,
        error: ClientUnknownServerError
    ) async -> T? {
        return await withCheckedContinuation { continuation in
            pendingOperation = ConflictOperation(
                error: error,
                onConfirm: {
                    Task {
                        do {
                            let result = try await operation(true)
                            continuation.resume(returning: result)
                        } catch {
                            continuation.resume(returning: nil)
                        }
                    }
                },
                onCancel: {
                    continuation.resume(returning: nil)
                }
            )
        }
    }
}

private struct ConflictOperation {
    let error: ClientUnknownServerError
    let onConfirm: @MainActor () -> Void
    let onCancel: @MainActor () -> Void
}

extension ClientUnknownServerError {
    fileprivate var isLectureConflictError: Bool {
        errorCode == 12300
    }

    fileprivate var errorMessage: String {
        [failureReason, recoverySuggestion]
            .compactMap(\.self)
            .joined(separator: " ")
    }
}

extension View {
    public func handleLectureTimeConflict() -> some View {
        modifier(LectureTimeConflictHandlingModifier())
    }
}

private struct LectureTimeConflictHandlingModifier: ViewModifier {
    @State private var conflictHandler = LectureTimeConflictHandler()
    public func body(content: Content) -> some View {
        content
            .environment(\.lectureTimeConflictHandler, conflictHandler)
            .alert(
                isPresented: conflictHandler.isConflictAlertPresented,
                error: conflictHandler.pendingOperation?.error
            ) { _ in
                Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {
                    conflictHandler.pendingOperation?.onCancel()
                }
                Button(TimetableStrings.editConflictForceAdd) {
                    conflictHandler.pendingOperation?.onConfirm()
                }
            } message: { error in
                Text(error.errorMessage)
            }
    }
}

extension EnvironmentValues {
    @Entry public var lectureTimeConflictHandler: LectureTimeConflictHandler = .init()
}
