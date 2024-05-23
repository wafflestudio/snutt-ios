//
//  SearchResultListView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit
import TimetableInterface
import SharedUIComponents

struct SearchResultListView: View {
    @ObservedObject var viewModel: LectureSearchViewModel

    var body: some View {
        ZStack {
            ShortcutsScrollView()
            if viewModel.lectures.isEmpty {
                SearchTipsView()
            } else {
                ExpandableLectureListView(viewModel: viewModel)
                    .padding(.top, 60)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

enum ShortcutType: Int, CaseIterable, Identifiable {
    var id: Int {
        rawValue
    }

    case manualAdd
    case vacancy
    case bookmark

    var title: String {
        switch self {
        case .manualAdd:
            "직접 추가"
        case .vacancy:
            "빈자리 알림"
        case .bookmark:
            "관심강좌"
        }
    }

    var subtitle: String {
        switch self {
        case .manualAdd:
            "4개"
        case .vacancy:
            "0개"
        case .bookmark:
            "0개"
        }
    }

    var image: UIImage {
        switch self {
        case .manualAdd:
                UIImage(systemName: "text.badge.plus")!
        case .vacancy:
            UIImage(systemName: "cursorarrow.rays")!
        case .bookmark:
            UIImage(systemName: "bookmark.circle.fill")!
        }
    }

}

struct ShortcutsScrollView: View {
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(ShortcutType.allCases) { shortcutType in
                        AnimatableButton {

                        } configuration: { button in
                            var config = UIButton.Configuration.plain()
                            config.attributedTitle = .init(shortcutType.title, attributes: .init([.font: UIFont.systemFont(ofSize: 12, weight: .semibold)]))
                            config.attributedSubtitle = .init(shortcutType.subtitle, attributes: .init([.font: UIFont.systemFont(ofSize: 11), .foregroundColor: UIColor.white.withAlphaComponent(0.6)]))
                            config.baseForegroundColor = .white.withAlphaComponent(0.9)
                            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                            config.background.strokeColor = .label.withAlphaComponent(0.1)
                            config.background.strokeWidth = 0.5
                            config.background.customView = blurView
                            config.titleAlignment = .leading
                            config.image = shortcutType.image
                            config.imagePlacement = .leading
                            config.preferredSymbolConfigurationForImage = .init(pointSize: 14)
                            config.imagePadding = 8
                            return config
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 10)
                .frame(height: 60)
            }
            Spacer()
        }
    }
}

#Preview {
//    let viewModel = LectureSearchViewModel()
//    let _  = Task {
//        await viewModel.fetchInitialSearchResult()
//    }
//    SearchResultListView(viewModel: viewModel)
    ZStack {
        Color.blue.opacity(0.8)
        ShortcutsScrollView()
    }
}

