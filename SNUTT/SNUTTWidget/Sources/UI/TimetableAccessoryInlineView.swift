//
//  TimetableAccessoryInlineView.swift
//  SNUTTWidgetExtension
//
//  Created by 박신홍 on 2023/04/05.
//

import SwiftUI
import TimetableInterface

struct TimetableAccessoryInlineView: View {
    var entry: TimelineProvider.Entry

    var body: some View {
        loadImage("logo.inline", targetHeight: 15)

        if let lectureTimes = entry.currentTimetable?.getRemainingLectureTimes(on: entry.date, by: .startTime),
           let firstLectureTime = lectureTimes.get(at: 0)
        {
            Text("\(firstLectureTime.lecture.courseTitle)")
        } else if isLoginRequired {
            loginRequiredView
        } else if isTimetableEmpty {
            emptyTimetableView
        } else {
            emptyRemainingLecturesView
        }
    }
}

extension TimetableAccessoryInlineView: TimetableWidgetViewProtocol {
    var loginRequiredView: some View {
        Text("로그인 필요")
    }

    var emptyTimetableView: some View {
        Text("-")
    }

    var emptyRemainingLecturesView: some View {
        Text("남은 강의 없음")
    }
}

extension TimetableAccessoryInlineView {
    /// Attempt to load the specified image from the app bundle resources,
    /// as the `.accessoryInline` widget cannot access images from the Assets catalog.
    /// If the image fails to load, use a default calendar symbol as a fallback.
    func loadImage(_ imageName: String, targetHeight: CGFloat, fallback: String = "calendar") -> some View {
        // try to load logo image from bundle resources,
        // because accessoryInline widget does not read images from Assets.
        guard let url = Bundle.main.url(forResource: imageName, withExtension: "png"),
              let data = try? Data(contentsOf: url),
              let uiImage = UIImage(data: data)
        else {
            // fallback to default symbol
            return Image(systemName: fallback)
        }

        let heightRatio = targetHeight / uiImage.size.height
        let newSize = CGSize(width: uiImage.size.width * heightRatio, height: uiImage.size.height * heightRatio)
        let resizedImage = uiImage.resized(to: newSize)
        return Image(uiImage: resizedImage)
    }
}

private extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
