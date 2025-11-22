import Dependencies
import Foundation
import Spyable

@Spyable
public protocol SemesterRepository: Sendable {
    /// Fetches the current and next semester status information
    func fetchSemesterStatus() async throws -> SemesterStatus
}
