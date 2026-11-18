#if FEATURE_LECTURE_DIARY
import AnalyticsInterface
import ConcurrencyExtras
import Dependencies
import Foundation
import Testing

@testable import LectureDiary

@MainActor
struct EditLectureDiaryViewModelAnalyticsTests {
    private struct SubmitFailure: Error {}

    private let logger = AnalyticsLoggerSpy()
    private let repository = LectureDiaryRepositorySpy()

    private func makeViewModel(now: @escaping @Sendable () -> Date) -> EditLectureDiaryViewModel {
        withDependencies {
            $0.analyticsLogger = logger
            $0.lectureDiaryRepository = repository
            $0.date = DateGenerator(now)
        } operation: {
            EditLectureDiaryViewModel(lectureID: "lecture", lectureTitle: "title", referrer: .history)
        }
    }

    private var loggedEvents: [any AnalyticsLogEvent] {
        logger.logEventReceivedInvocations
    }

    @Test func submitLogsDiarySubmittedAfterServerSuccess() async throws {
        let clock = LockIsolated(Date(timeIntervalSince1970: 0))
        let viewModel = makeViewModel { clock.value }
        viewModel.classTypes = [.init(id: "id-lecture", content: "강의"), .init(id: "id-exam", content: "시험")]
        viewModel.selectedClassTypes = .init(selected: ["시험"])
        viewModel.extraComment = "좋았어요"
        viewModel.markEntered()
        clock.setValue(Date(timeIntervalSince1970: 42))

        try await viewModel.submitDiary()

        let event = try #require(loggedEvents.last as? AnalyticsAction)
        guard case .diarySubmitted(let parameter) = event else {
            Issue.record("Expected diary_submitted, got \(event.eventName)")
            return
        }
        #expect(
            parameter
                == DiarySubmittedParameter(
                    activityTypeIDs: ["id-exam"],
                    hasComment: true,
                    elapsedSeconds: 42,
                    referrer: .history
                )
        )
        #expect(event.parameters?["activity_count"] == "1")
    }

    @Test func submitFailureDoesNotLogDiarySubmitted() async {
        let viewModel = makeViewModel { Date(timeIntervalSince1970: 0) }
        repository.submitDiaryThrowableError = SubmitFailure()

        await #expect(throws: SubmitFailure.self) {
            try await viewModel.submitDiary()
        }
        #expect(!loggedEvents.contains { $0.eventName == "diary_submitted" })
        #expect(!viewModel.isSubmitting)
    }

    @Test func secondSubmitAfterSuccessIsRejected() async throws {
        let viewModel = makeViewModel { Date(timeIntervalSince1970: 0) }
        try await viewModel.submitDiary()

        await #expect(throws: CancellationError.self) {
            try await viewModel.submitDiary()
        }
        #expect(repository.submitDiaryCallsCount == 1)
    }

    @Test func exitBeforeQuestionsLogsActivityStepOnce() {
        let clock = LockIsolated(Date(timeIntervalSince1970: 0))
        let viewModel = makeViewModel { clock.value }
        viewModel.markEntered()
        clock.setValue(Date(timeIntervalSince1970: 5))

        viewModel.logExitWithoutSubmit()
        viewModel.logExitWithoutSubmit()

        let exits = loggedEvents.compactMap { $0 as? AnalyticsAction }.filter { $0.eventName == "diary_write_exit" }
        #expect(exits.count == 1)
        #expect(exits.first?.parameters == ["step": "activity", "elapsed_sec": "5", "referrer": "history"])
    }

    @Test func exitAfterQuestionsLogsQuestionsStep() async {
        let viewModel = makeViewModel { Date(timeIntervalSince1970: 0) }
        repository.fetchQuestionnaireForWithReturnValue = QuestionnaireItem(
            lectureTitle: "title",
            questions: [],
            nextLecture: nil
        )
        viewModel.markEntered()

        await viewModel.loadQuestionnaire()
        viewModel.logExitWithoutSubmit()

        let exit = loggedEvents.last { $0.eventName == "diary_write_exit" }
        #expect(exit?.parameters?["step"] == "questions")
    }

    @Test func diaryWriteScreenCarriesReferrer() {
        #expect(AnalyticsScreen.diaryWrite(referrer: .push).parameters == ["referrer": "push"])
        #expect(AnalyticsScreen.diaryHistory.eventName == "diary_history")
    }
}
#endif
