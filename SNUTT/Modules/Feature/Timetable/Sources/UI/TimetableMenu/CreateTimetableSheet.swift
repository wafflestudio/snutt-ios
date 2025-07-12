import SharedUIComponents
import SwiftUI
import TimetableInterface

struct CreateTimetableSheet: View {
    let viewModel: TimetableMenuViewModel
    let presentationType: PresentationType

    enum PresentationType: Equatable {
        case picker
        case fixed(Quarter)
    }

    var hasQuarterPicker: Bool {
        presentationType == .picker
    }

    @State private var title: String = ""
    @State private var selectedQuarter: Quarter?
    @FocusState private var titleFocus: Bool
    @State private var isCreateLoading = false
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) var dismiss

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 20) {
                SheetTopBar(
                    cancel: {
                        dismiss()
                    },
                    confirm: {
                        let targetQuarter =
                            switch presentationType {
                            case .picker:
                                selectedQuarter
                            case let .fixed(quarter):
                                quarter
                            }
                        guard let targetQuarter else { return }
                        isCreateLoading = true
                        Task {
                            await errorAlertHandler.withAlert {
                                try await viewModel.createTimetable(
                                    title: title,
                                    quarter: targetQuarter
                                )
                            }
                            isCreateLoading = false
                            dismiss()
                        }
                    },
                    isConfirmDisabled: isCreateLoading || title.isEmpty
                        || (!hasQuarterPicker ? false : selectedQuarter == nil)
                )

                AnimatableTextField(label: "시간표 제목", placeholder: "시간표 제목을 입력하세요", text: $title)
                    .focused($titleFocus)
                    .onAppear {
                        titleFocus = true
                    }
                    .padding(.horizontal)

                if hasQuarterPicker, !viewModel.availableQuarters.isEmpty {
                    Picker("학기", selection: $selectedQuarter) {
                        ForEach(viewModel.availableQuarters, id: \.id) { quarter in
                            Text(quarterDisplayName(quarter)).tag(quarter as Quarter?)
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.horizontal)
                }
            }
        }
        .presentationDetents([.height(hasQuarterPicker ? 300 : 120)])
        .observeErrors()
        .onAppear {
            if hasQuarterPicker {
                selectedQuarter = viewModel.availableQuarters.first
            }
        }
    }

    private func quarterDisplayName(_ quarter: Quarter) -> String {
        let semesterName =
            switch quarter.semester {
            case .first: "1학기"
            case .summer: "여름학기"
            case .second: "2학기"
            case .winter: "겨울학기"
            }
        return "\(quarter.year)년 \(semesterName)"
    }
}
