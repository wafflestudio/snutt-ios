//
//  VacancyScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ConfigsInterface

public struct VacancyScene: View {
    @AppStorage("isNewToVacancyService") private var isNewToVacancyService: Bool = true
    @State private var viewModel = VacancyViewModel()
    @State private var editMode: EditMode = .inactive
    @State private var isGuidePopupPresented = false
    @State private var sugangSnuURL: URL?
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.configs) private var configs
    @Environment(\.openURL) private var openURL

    private var shouldShowGuidePopup: Bool {
        isNewToVacancyService || isGuidePopupPresented
    }

    public var body: some View {
        ZStack {
            VacancyLectureListView(viewModel: viewModel, editMode: $editMode)
                .task {
                    errorAlertHandler.withAlert {
                        try await viewModel.fetchVacancyLectures()
                    }
                }

            if viewModel.vacancyLectures.isEmpty {
                VacancyEmptyListView {
                    isGuidePopupPresented = true
                }
            }

            if shouldShowGuidePopup {
                VacancyGuidePopup(dismiss: {
                    isNewToVacancyService = false
                    isGuidePopupPresented = false
                })
                .transition(.opacity.animation(.defaultSpring))
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
                        VacancyAsset.vacancyInfo.swiftUIImage
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
                if let sugangSnuUrl = configs.vacancySugangSnuUrl?.url {
                    openURL(sugangSnuUrl)
                }
            }
            .padding()
            .opacity(editMode.isEditing ? 0 : 1)
            .offset(x: 0, y: editMode.isEditing ? 100 : 0)
            .animation(.defaultSpring, value: editMode)
            .disabled(shouldShowGuidePopup)
        }
    }
}

#Preview {
    NavigationStack {
        VacancyScene()
    }
}
