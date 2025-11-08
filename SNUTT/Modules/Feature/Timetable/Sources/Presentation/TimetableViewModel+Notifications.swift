//
//  TimetableViewModel+Notifications.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import SharedUIComponents
import TimetableInterface

extension TimetableViewModel {
    func subscribeToNotifications() {
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToNotificationsMessage.self)
        ) { @MainActor viewModel, _ in
            viewModel.paths = [.notificationList]
        }
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToLectureMessage.self)
        ) { @MainActor viewModel, message in
            await viewModel.handleLectureNavigation(message: message)
        }
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToTimetableMessage.self)
        ) { @MainActor viewModel, message in
            do {
                try await viewModel.selectTimetable(timetableID: message.timetableID)
                viewModel.paths = []
            } catch {
                viewModel.notificationCenter.post(
                    .toast(.init(message: TimetableStrings.navigationErrorTimetableNotFound))
                )
            }
        }
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: NavigateToBookmarkLecturePreviewMessage.self)
        ) { @MainActor viewModel, message in
            await viewModel.handleBookmarkLecturePreviewNavigation(message: message)
        }
    }

    private func handleLectureNavigation(message: NavigateToLectureMessage) async {
        do {
            let timetable = try await timetableRepository.fetchTimetable(timetableID: message.timetableID)
            guard let lecture = timetable.lectures.first(where: { $0.lectureID == message.lectureID })
            else {
                notificationCenter.post(.toast(.init(message: TimetableStrings.navigationErrorLectureNotFound)))
                return
            }
            paths = [.notificationList, .lectureDetail(lecture, parentTimetable: timetable)]
            analyticsLogger.logScreen(
                AnalyticsScreen.lectureDetail(.init(lectureID: lecture.referenceID, referrer: .notification))
            )
        } catch let error as any ErrorWrapper {
            notificationCenter.post(.toast(error: error))
        } catch {
            notificationCenter.post(.toast(.init(message: TimetableStrings.navigationErrorUnknown)))
        }
    }

    private func handleBookmarkLecturePreviewNavigation(message: NavigateToBookmarkLecturePreviewMessage) async {
        do {
            let quarter = Quarter(year: message.year, semester: message.semester)
            let bookmarks = try await lectureRepository.fetchBookmarks(quarter: quarter)
            guard let lecture = bookmarks.first(where: { $0.referenceID == message.lectureID })
            else {
                notificationCenter.post(.toast(.init(message: TimetableStrings.navigationErrorBookmarkNotFound)))
                return
            }
            paths = [.notificationList, .lecturePreview(lecture, quarter: quarter)]
            analyticsLogger.logScreen(
                AnalyticsScreen.lectureDetail(.init(lectureID: lecture.referenceID, referrer: .notification))
            )
        } catch let error as any ErrorWrapper {
            notificationCenter.post(.toast(error: error))
        } catch {
            notificationCenter.post(.toast(.init(message: TimetableStrings.navigationErrorUnknown)))
        }
    }
}
