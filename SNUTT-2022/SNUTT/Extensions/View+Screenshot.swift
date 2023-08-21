//
//  View+Screenshot.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import SwiftUI

extension View {
    /// Take a screenshot of View. The default size is `Full-sized screen` of device. Use `GeometryReader` to get an exact-sized screenshot of View.
    /// The origin of screenshot is `.zero`.
    func takeScreenshot(size: CGSize = UIScreen.main.bounds.size, preferredColorScheme: ColorScheme? = nil) -> UIImage {
        let viewController = UIHostingController(rootView: self.ignoresSafeArea(.all))
        viewController.view.frame = CGRect(origin: .zero, size: size)
        viewController.overrideUserInterfaceStyle = UIUserInterfaceStyle(preferredColorScheme)

        let renderer = UIGraphicsImageRenderer(bounds: viewController.view.bounds)
        return renderer.image { context in
            viewController.view.drawHierarchy(in: viewController.view.bounds, afterScreenUpdates: true)
        }
    }
}
