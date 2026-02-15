//
//  TaskSubscribeTests.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Foundation
import SwiftUtility
import Testing

// MARK: - Tests

struct TaskSubscribeTests {
    @MainActor
    @Test("Task processes elements while owner is alive")
    func taskProcessesElementsWhileOwnerIsAlive() async throws {
        let stream = AsyncStream.makeStream(of: Int.self)
        var owner: TestViewController? = .init()
        var items = [Int]()
        let task = Task.scoped(to: try #require(owner), subscribing: stream.stream) { @MainActor owner, element in
            items.append(element)
        }
        try await Task.sleep(for: .milliseconds(10))
        stream.continuation.yield(1)
        try await Task.sleep(for: .milliseconds(10))
        stream.continuation.yield(2)
        try await Task.sleep(for: .milliseconds(10))
        owner = nil
        try await Task.sleep(for: .milliseconds(10))
        stream.continuation.yield(3)
        try await Task.sleep(for: .milliseconds(10))
        #expect(items == [1, 2])
        await #expect(throws: CancellationError.self) {
            try await task.value
        }
        stream.continuation.finish()
    }

    @MainActor
    @Test("Task respects manual cancellation")
    func taskRespectsManualCancellation() async throws {
        let stream = AsyncStream.makeStream(of: Int.self)
        let owner = TestViewController()
        var items = [Int]()

        let task = Task.scoped(to: owner, subscribing: stream.stream) { @MainActor _, element in
            items.append(element)
        }

        // Emit initial elements
        stream.continuation.yield(1)
        try await Task.sleep(for: .milliseconds(10))
        stream.continuation.yield(2)
        try await Task.sleep(for: .milliseconds(10))

        // Verify elements received
        #expect(items == [1, 2])

        // Manually cancel task
        task.cancel()
        try await Task.sleep(for: .milliseconds(10))

        // Emit more elements after cancellation
        stream.continuation.yield(3)
        try await Task.sleep(for: .milliseconds(10))
        stream.continuation.yield(4)
        try await Task.sleep(for: .milliseconds(10))

        // Verify no elements received after cancellation
        #expect(items == [1, 2])
        #expect(task.isCancelled == true)

        stream.continuation.finish()
    }

    @MainActor
    @Test("Task handles errors thrown by onElement closure")
    func taskHandlesErrorsThrownByOnElementClosure() async throws {
        let stream = AsyncStream.makeStream(of: Int.self)
        let owner = TestViewController()
        var items = [Int]()

        let task = Task.scoped(to: owner, subscribing: stream.stream) { @MainActor _, element in
            items.append(element)
            if element == 2 {
                throw TestError.intentionalFailure
            }
        }

        // Emit elements
        stream.continuation.yield(1)
        try await Task.sleep(for: .milliseconds(10))
        stream.continuation.yield(2)  // This will throw
        try await Task.sleep(for: .milliseconds(10))

        // Verify first element was processed
        #expect(items == [1, 2])

        // Task should have failed
        await #expect(throws: TestError.self) {
            try await task.value
        }
        stream.continuation.finish()
    }
}

@MainActor
private final class TestViewController {}

private enum TestError: Error {
    case intentionalFailure
}
