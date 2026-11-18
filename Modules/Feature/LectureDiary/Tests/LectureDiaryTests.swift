#if FEATURE_LECTURE_DIARY
import AnalyticsInterface
import Dependencies
import Foundation
import Testing

@testable import LectureDiary

@MainActor
struct EditLectureDiaryViewModelAnalyticsTests {
    private struct SubmitFailure: Error {}

    private let logger = AnalyticsLoggerSpy()
    private let repository = LectureDiaryRepositorySpy()

    private func makeViewModel() -> EditLectureDiaryViewModel {
        withDependencies {
            $0.analyticsLogger = logger
            $0.lectureDiaryRepository = repository
        } operation: {
            EditLectureDiaryViewModel(lectureID: "lecture", lectureTitle: "title", referrer: .history)
        }
    }

    private var loggedEvents: [any AnalyticsLogEvent] {
        logger.logEventReceivedInvocations
    }

    @Test func submitLogsDiarySubmittedAfterServerSuccess() async throws {
        let viewModel = makeViewModel()
        viewModel.classTypes = [.init(id: "id-lecture", content: "강의"), .init(id: "id-exam", content: "시험")]
        viewModel.selectedClassTypes = .init(selected: ["시험"])
        viewModel.extraComment = "좋았어요"

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
                    referrer: .history
                )
        )
        #expect(event.parameters?["activity_count"] == "1")
    }

    @Test func submitFailureDoesNotLogDiarySubmitted() async {
        let viewModel = makeViewModel()
        repository.submitDiaryThrowableError = SubmitFailure()

        await #expect(throws: SubmitFailure.self) {
            try await viewModel.submitDiary()
        }
        #expect(!loggedEvents.contains { $0.eventName == "diary_submitted" })
        #expect(!viewModel.isSubmitting)
    }

    @Test func secondSubmitAfterSuccessIsRejected() async throws {
        let viewModel = makeViewModel()
        try await viewModel.submitDiary()

        await #expect(throws: CancellationError.self) {
            try await viewModel.submitDiary()
        }
        #expect(repository.submitDiaryCallsCount == 1)
    }

    @Test func exitBeforeQuestionsLogsActivityStepOnce() {
        let viewModel = makeViewModel()

        viewModel.logExitWithoutSubmit()
        viewModel.logExitWithoutSubmit()

        let exits = loggedEvents.compactMap { $0 as? AnalyticsAction }.filter { $0.eventName == "diary_write_exit" }
        #expect(exits.count == 1)
        #expect(exits.first?.parameters == ["step": "activity", "referrer": "history"])
    }

    @Test func exitAfterQuestionsLogsQuestionsStep() async {
        let viewModel = makeViewModel()
        repository.fetchQuestionnaireForWithReturnValue = QuestionnaireItem(
            lectureTitle: "title",
            questions: [],
            nextLecture: nil
        )
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
