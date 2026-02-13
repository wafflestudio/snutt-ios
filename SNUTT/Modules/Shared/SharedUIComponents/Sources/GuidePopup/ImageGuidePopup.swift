//
//  ImageGuidePopup.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct ImageGuidePopup: View {
    // MARK: - Constants

    private enum Layout {
        static let closeButtonSize: CGFloat = 15
        static let closeButtonPadding: CGFloat = 16
        static let closeButtonInactiveOpacity: CGFloat = 0.2
        static let navigationButtonSize: CGFloat = 30
        static let navigationButtonHorizontalPadding: CGFloat = 5
        static let estimatedIndicatorHeight: CGFloat = 50
    }

    // MARK: - Properties

    public let guideImages: [UIImage]

    @State private var currentGuideIndex = 0
    @Environment(\.popupDismiss) private var popupDismiss

    // MARK: - Computed Properties

    private var isFirstPage: Bool {
        currentGuideIndex == 0
    }

    private var isLastPage: Bool {
        currentGuideIndex == guideImages.count - 1
    }

    private var maxImageHeight: CGFloat {
        guideImages.map { $0.size.height }.max() ?? 100
    }

    // MARK: - Initialization

    public init(guideImages: [UIImage]) {
        self.guideImages = guideImages
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            closeButton
            imageCarousel
        }
    }

    // MARK: - View Components

    private var closeButton: some View {
        HStack {
            Spacer()
            Button {
                popupDismiss()
            } label: {
                SharedUIComponentsAsset.guidePopupXmark.swiftUIImage
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.closeButtonSize, height: Layout.closeButtonSize)
                    .foregroundStyle(Color(uiColor: .label))
            }
            .opacity(isLastPage ? 1 : Layout.closeButtonInactiveOpacity)
            .padding(Layout.closeButtonPadding)
        }
    }

    private var imageCarousel: some View {
        TabView(selection: $currentGuideIndex) {
            ForEach(guideImages.indices, id: \.self) { index in
                Image(uiImage: guideImages[index])
                    .resizable()
                    .scaledToFit()
                    .tag(index)
                    .padding(.bottom, Layout.estimatedIndicatorHeight)
            }
        }
        .frame(maxHeight: maxImageHeight + Layout.estimatedIndicatorHeight)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .overlay {
            navigationButtons
        }
    }

    private var navigationButtons: some View {
        HStack {
            if !isFirstPage {
                GuideNavigationButton(
                    image: SharedUIComponentsAsset.guideChevronLeft.swiftUIImage
                ) {
                    currentGuideIndex -= 1
                }
            }

            Spacer()

            if !isLastPage {
                GuideNavigationButton(
                    image: SharedUIComponentsAsset.guideChevronRight.swiftUIImage
                ) {
                    currentGuideIndex += 1
                }
            }
        }
        .padding(.horizontal, Layout.navigationButtonHorizontalPadding)
    }
}

// MARK: - Supporting Views

extension ImageGuidePopup {
    struct GuideNavigationButton: View {
        let image: Image
        let action: () -> Void

        @State private var isPressed = false

        var body: some View {
            Button {
                withAnimation(.defaultSpring) {
                    action()
                }
            } label: {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: ImageGuidePopup.Layout.navigationButtonSize)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
        }
    }
}

// MARK: - Preview

#Preview("Single Image") {
    ImageGuidePopup(
        guideImages: [
            SharedUIComponentsAsset.logo.image
        ]
    )
    .environment(\.popupDismiss, .init(action: {}))
}

//#Preview("Multiple Images") {
//    ImageGuidePopup(
//        guideImages: [
//            Image(systemName: "star.fill"),
//            Image(systemName: "heart.fill"),
//            Image(systemName: "flame.fill"),
//            Image(systemName: "bolt.fill"),
//        ]
//    ) {}
//}
