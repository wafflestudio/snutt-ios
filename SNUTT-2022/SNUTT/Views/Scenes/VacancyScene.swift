//
//  VacancyScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/22.
//

import Foundation
import SwiftUI

struct VacancyScene: View, Sendable {
    @ObservedObject var viewModel: ViewModel
    @AppStorage("isNewToVacancyService") private var isNewToVacancyService: Bool = true
    @State private var editMode = EditMode.inactive
    @State private var isGuidePopupPresented = false
    @State private var sugangSnuUrl: URL? = nil
    @Environment(\.openURL) var openURL

    private var showGuidePopup: Bool {
        isNewToVacancyService || isGuidePopupPresented
    }

    var body: some View {
        ZStack {
            VacancyLectureList(viewModel: viewModel, editMode: $editMode, isGuidePopupPresented: isGuidePopupPresented)
                .task {
                    await viewModel.fetchLectures()
                }

            if viewModel.lectures.isEmpty {
                VacancyEmptyListView {
                    isGuidePopupPresented = true
                }
            }

            if showGuidePopup {
                VacancyGuidePopup(dismiss: {
                    isNewToVacancyService = false
                    isGuidePopupPresented = false
                })
                .transition(.opacity.animation(.customSpring))
            }
        }
        .onDisappear {
            editMode = .inactive
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 0) {
                    Text("빈자리 알림").font(.headline)
                    Button {
                        isGuidePopupPresented = true
                    } label: {
                        Image("vacancy.info")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 17)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottomTrailing) {
            VacancySugangSnuButton {
                if let sugangSnuUrl {
                    openURL(sugangSnuUrl)
                }
            }
            .padding()
            .opacity(editMode.isEditing ? 0 : 1)
            .offset(x: 0, y: editMode.isEditing ? 100 : 0)
            .animation(.customSpring, value: editMode)
            .disabled(showGuidePopup)
        }
        .task {
            sugangSnuUrl = await viewModel.fetchSugangSnuUrl()
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

        func fetchSugangSnuUrl() async -> URL? {
            do {
                return try await vacancyService.fetchSugangSnuUrl()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
            return nil
        }
    }
}
