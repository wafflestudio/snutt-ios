//
//  VacancyGuidePopup.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct VacancyGuidePopup: View {
    let dismiss: () -> Void

    @State private var currentGuideIndex = 0

    var guideImages: [Image] {
        [
            VacancyAsset.vacancyGuide1.swiftUIImage,
            VacancyAsset.vacancyGuide2.swiftUIImage,
            VacancyAsset.vacancyGuide3.swiftUIImage,
            VacancyAsset.vacancyGuide4.swiftUIImage,
        ]
    }

    var imageIndices: Range<Int> {
        0 ..< guideImages.count
    }

    var body: some View {
        GeometryReader { reader in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        dismiss()
                    }
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            VacancyAsset.vacancyXmark.swiftUIImage
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15)
                                .padding([.top, .trailing])
                                .foregroundColor(Color(uiColor: .label))
                                .opacity(currentGuideIndex == imageIndices.last ? 1 : 0.2)
                        }
                    }
                    ZStack {
                        TabView(selection: $currentGuideIndex) {
                            ForEach(0 ..< 4) { imageNum in
                                VStack {
                                    guideImages[imageNum]
                                        .resizable()
                                        .scaledToFit()
                                        .padding(.horizontal, 30)
                                        .padding(.top, 10)
                                    Spacer()
                                }
                                .tag(imageNum)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))

                        HStack {
                            if currentGuideIndex != imageIndices.first {
                                GuideNavigationButton(
                                    image: VacancyAsset.vacancyChevronLeft.swiftUIImage,
                                    updateIndex: {
                                        currentGuideIndex = max(currentGuideIndex - 1, 1)
                                    }
                                )
                            }
                            Spacer()
                            if currentGuideIndex != imageIndices.last {
                                GuideNavigationButton(
                                    image: VacancyAsset.vacancyChevronLeft.swiftUIImage,
                                    updateIndex: {
                                        currentGuideIndex = min(currentGuideIndex + 1, imageIndices.last ?? 1)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .background(SharedUIComponentsAsset.systemBackground.swiftUIColor)
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = .label.withAlphaComponent(0.5)
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.1)
                }
                .padding(.horizontal, reader.size.width * 0.1)
                .frame(height: 320)
            }
        }
    }

    struct GuideNavigationButton: View {
        let image: Image
        let updateIndex: () -> Void

        var body: some View {
            Button {
                withAnimation(.defaultSpring) {
                    updateIndex()
                }
            } label: {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    VacancyGuidePopup(dismiss: {})
}
