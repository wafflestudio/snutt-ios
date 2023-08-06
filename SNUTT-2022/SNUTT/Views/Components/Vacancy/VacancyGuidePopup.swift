//
//  VacancyGuidePopup.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/08/06.
//

import SwiftUI

struct VacancyGuidePopup: View {
    let dismiss: () -> Void

    private static let imageIndices = Array(1 ... 4)
    @State private var currentGuideIndex = 1

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
                            Image("vacancy.xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 15)
                                .padding([.top, .trailing])
                        }
                    }
                    ZStack {
                        TabView(selection: $currentGuideIndex) {
                            ForEach(Self.imageIndices, id: \.hashValue) { imageNum in
                                VStack {
                                    Image("vacancy.guide\(imageNum)")
                                        .resizable()
                                        .scaledToFit()
                                        .padding()
                                    Spacer()
                                }
                                .tag(imageNum)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))

                        HStack {
                            if currentGuideIndex != Self.imageIndices.first {
                                GuideNavigationButton(imageName: "vacancy.chevron.left", updateIndex: {
                                    currentGuideIndex = max(currentGuideIndex - 1, 1)
                                })
                            }
                            Spacer()
                            if currentGuideIndex != Self.imageIndices.last {
                                GuideNavigationButton(imageName: "vacancy.chevron.right", updateIndex: {
                                    currentGuideIndex = min(currentGuideIndex + 1, Self.imageIndices.last ?? 1)
                                })
                            }
                        }
                    }
                }
                .background(STColor.systemBackground)
                .onAppear {
                    UIPageControl.appearance().currentPageIndicatorTintColor = .label.withAlphaComponent(0.5)
                    UIPageControl.appearance().pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.1)
                }
                .padding(.horizontal, reader.size.width * 0.1)
                .frame(height: reader.size.height * 0.5)
            }
        }
    }

    struct GuideNavigationButton: View {
        let imageName: String
        let updateIndex: () -> Void

        var body: some View {
            Button {
                withAnimation(.customSpring) {
                    updateIndex()
                }
            } label: {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
            }
            .buttonStyle(.plain)
        }
    }
}

struct VacancyGuidePopup_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { reader in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.5))
                    .ignoresSafeArea(.all)
                VacancyGuidePopup(dismiss: {})
                    .padding(.horizontal, reader.size.width * 0.1)
                    .frame(height: 400)
            }
        }
    }
}
