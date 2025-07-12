//
//  LectureTimeConflictHandler.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
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
        } catch let error as any APIClientError where error.localizedCode == .lectureTimeOverlap {
            return await handleConflictError(operation: operation, error: error.localizedCode!)
        } catch {
            // conflict가 아닌 다른 에러는 다시 throw
            throw error
        }
    }

    private func handleConflictError<T: Sendable>(
        operation: @escaping (_ overrideOnConflict: Bool) async throws -> T,
        error: LocalizedErrorCode
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
    let error: LocalizedErrorCode
    let onConfirm: @MainActor () -> Void
    let onCancel: @MainActor () -> Void
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
                Button("취소", role: .cancel) {
                    conflictHandler.pendingOperation?.onCancel()
                }
                Button("강제 추가") {
                    conflictHandler.pendingOperation?.onConfirm()
                }
            } message: { error in
                Text("\(error.failureReason ?? "") 그래도 추가하시겠습니까?")
            }
    }
}

extension EnvironmentValues {
    @Entry public var lectureTimeConflictHandler: LectureTimeConflictHandler = .init()
}
