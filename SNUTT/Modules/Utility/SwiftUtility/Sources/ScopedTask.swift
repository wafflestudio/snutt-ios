//
//  Task+Extensions.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

typealias TaskCancellationError = CancellationError
extension Task where Success == Void, Failure == any Error {
    /// Creates a task scoped to an owner's lifetime that subscribes to an AsyncSequence.
    ///
    /// This method creates a task that iterates over an async sequence and calls the provided
    /// closure for each element. The task is scoped to the owner's lifetime through a weak reference,
    /// automatically throwing `CancellationError` when the owner is deallocated to prevent
    /// retain cycles and unnecessary work.
    ///
    /// - Parameters:
    ///   - owner: The object that owns this subscription (weakly referenced)
    ///   - stream: The AsyncSequence to subscribe to
    ///   - priority: Optional task priority (defaults to nil)
    ///   - onElement: Closure called for each element with the owner and element
    ///
    /// - Returns: The created task, which can be stored or canceled manually
    ///
    /// - Throws: `CancellationError` when the owner is deallocated during iteration
    ///
    /// Example:
    /// ```swift
    /// class MyViewModel {
    ///     init() {
    ///         Task.scoped(
    ///             to: self,
    ///             subscribing: notificationCenter.notifications(named: .didBecomeActive)
    ///         ) { (self, notification) in
    ///             await self.handleNotification(notification)
    ///         }
    ///     }
    /// }
    /// ```
    @discardableResult
    public static func scoped<Owner: AnyObject, S: AsyncSequence>(
        to owner: Owner,
        subscribing stream: sending S,
        priority: TaskPriority? = nil,
        onElement: @escaping @Sendable (Owner, S.Element) async throws -> Void
    ) -> Task<Success, Failure> where Owner: Sendable, S: SendableMetatype {
        return self.init(priority: priority) { [weak weakOwner = owner] in
            for try await element in stream {
                guard let strongOwner = weakOwner else { throw TaskCancellationError() }
                try await onElement(strongOwner, element)
            }
        }
    }
}
