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
    func takeScreenshot(
        size: CGSize = UIScreen.main.bounds.size,
        preferredColorScheme: ColorScheme? = nil
    ) -> UIImage {
        let viewController = UIHostingController(rootView: self.ignoresSafeArea())
        viewController.view.frame = CGRect(origin: .zero, size: size)
        viewController.overrideUserInterfaceStyle = UIUserInterfaceStyle(preferredColorScheme)

        let renderer = UIGraphicsImageRenderer(bounds: viewController.view.bounds)
        return renderer.image { context in
            viewController.view.drawHierarchy(in: viewController.view.bounds, afterScreenUpdates: true)
        }
    }
    
    func createTimetableImage(
        size: CGSize = UIScreen.main.bounds.size,
        timetable: Timetable,
        timetableConfig: TimetableConfiguration,
        preferredColorScheme: ColorScheme? = nil
    ) -> Data {
        let renderer = UIGraphicsImageRenderer(bounds: .init(origin: .zero, size: size))
        return renderer.pngData { context in
            let timetableView = TimetableZStack(current: timetable, config: timetableConfig).ignoresSafeArea(.all)
            let viewController = UIHostingController(rootView: timetableView)
            viewController.view.frame = CGRect(origin: .zero, size: size)
            viewController.overrideUserInterfaceStyle = UIUserInterfaceStyle(preferredColorScheme)
            viewController.view.layer.render(in: context.cgContext)
            viewController.view.drawHierarchy(in: viewController.view.bounds, afterScreenUpdates: true)
        }
    }
}
