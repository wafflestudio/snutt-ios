//
//  View+Screenshot.swift
//  SNUTT
//
//  Created by 최유림 on 2022/11/04.
//

import SwiftUI

extension View {
    /// Create a png image of the timetable. The default size is `Full-sized screen` of device.
    func createTimetableImage(
        size: CGSize = UIScreen.main.bounds.size,
        timetable: Timetable,
        timetableConfig: TimetableConfiguration,
        preferredColorScheme: ColorScheme? = nil
    ) -> Data {
        let renderer = UIGraphicsImageRenderer(bounds: .init(origin: .zero, size: size))
        return renderer.pngData { _ in
            let timetableView = TimetableZStack(current: timetable, config: timetableConfig).ignoresSafeArea(.all)
            let viewController = UIHostingController(rootView: timetableView)
            viewController.view.frame = CGRect(origin: .zero, size: size)
            viewController.overrideUserInterfaceStyle = UIUserInterfaceStyle(preferredColorScheme)
            viewController.view.drawHierarchy(in: viewController.view.bounds, afterScreenUpdates: true)
        }
    }
}
