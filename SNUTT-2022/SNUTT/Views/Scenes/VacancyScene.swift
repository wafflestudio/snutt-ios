//
//  VacancyScene.swift
//  SNUTT
//
//  Created by user on 2023/07/22.
//

import Foundation
import SwiftUI

struct VacancyScene: View, Sendable {
    @StateObject var viewModel: ViewModel

    var body: some View {
        let _ = print(viewModel.lectures)
        VacancyLectureList(viewModel: viewModel)
        .task {
            await viewModel.fetchLectures()
        }
    }

}

extension VacancyScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var lectures: [Lecture] = []

        private var vacancyService: VacancyServiceProtocol {
            services.vacancyService
        }

        override init(container: DIContainer) {
            super.init(container: container)
            appState.vacancy.$lectures.assign(to: &$lectures)
        }

        func fetchLectures() async {
            do {
                try await vacancyService.fetchLectures()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func deleteLectures(lectures: [Lecture]) async {
            do {
                try await vacancyService.deleteLectures(lectures: lectures)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

