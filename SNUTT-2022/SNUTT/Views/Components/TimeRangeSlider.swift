//
//  TimeRangeSlider.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/03/10.
//

import SwiftUI

struct TimeRangeSliderConfig {
    var lineWidth: CGFloat = 5
    var handleDiameter: CGFloat = 20
    var minimumDistance = 6
    var tickCount = 24
    var tickMarkWidth: CGFloat = 2
}

struct TimeRangeSlider: View {
    @Binding var minHour: Int
    @Binding var maxHour: Int
    var config: TimeRangeSliderConfig = .init()

    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)

    struct SliderPath: Shape {
        func path(in rect: CGRect) -> Path {
            let height = rect.size.height
            return Path { path in
                path.move(to: .init(x: 0, y: height / 2))
                path.addLine(to: .init(x: rect.size.width, y: height / 2))
            }
        }
    }

    struct TickMarks: Shape {
        let tickCount: Int
        func path(in rect: CGRect) -> Path {
            let width = rect.size.width
            let centerY = rect.size.height / 2
            return Path { path in
                for i in 0 ... tickCount {
                    let x: Double = .init(i) * width / Double(tickCount)
                    let y: Double = i % 6 == 0 ? 5 : 2
                    path.move(to: CGPoint(x: x, y: centerY))
                    path.addLine(to: .init(x: x, y: centerY + y))
                }
            }
        }
    }

    struct SliderHandle: View {
        let hour: Int
        let offset: CGFloat
        let diameter: CGFloat
        let onChanged: (DragGesture.Value) -> Void

        @GestureState private var isDragging = false

        private var simultaneousGesture: some Gesture {
            // Gesture that toggles `isDragging` when pressed
            let initialGesture = DragGesture(minimumDistance: 0)
                .updating($isDragging, body: { _, state, _ in
                    state = true
                })
            // Gesture that reacts to the location changes
            let draggingGesture = DragGesture()
                .onChanged { value in
                    onChanged(value)
                }
            // Combine two gestures with different minimumDistance
            // to prevent jumps when pressed
            return draggingGesture.simultaneously(with: initialGesture)
        }

        var body: some View {
            Circle()
                .fill(Color.white)
                .frame(width: diameter)
                .shadow(radius: 1)
                .scaleEffect(isDragging ? 1.5 : 1.0)
                .offset(x: offset)
                .gesture(simultaneousGesture)
                .overlay {
                    Text("\(hour)시")
                        .fixedSize()
                        .font(.system(size: isDragging ? 14 : 12, weight: .bold))
                        .offset(x: offset, y: isDragging ? -25 : -20)
                        .opacity(0.8)
                }
                .animation(.customSpring, value: isDragging)
        }
    }

    func translateHourToWidth(hour: Int, reader: GeometryProxy) -> CGFloat {
        return CGFloat(hour) * reader.size.width / CGFloat(config.tickCount)
    }

    func translateWidthToHour(width: CGFloat, reader: GeometryProxy) -> Int {
        let normalizedWidth = max(min(width / reader.size.width, 1.0), 0.0)
        let hour = Int(round(Double(normalizedWidth) * Double(config.tickCount)))
        return hour
    }

    func calculatePercentage(hour: Int) -> Double {
        return Double(hour) / Double(config.tickCount)
    }

    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                SliderPath()
                    .stroke(Color(uiColor: .quaternaryLabel).opacity(0.5), style: StrokeStyle(lineWidth: config.lineWidth, lineCap: .round, lineJoin: .round))

                TickMarks(tickCount: config.tickCount)
                    .stroke(Color(uiColor: .quaternaryLabel).opacity(0.5), style: StrokeStyle(lineWidth: config.tickMarkWidth, lineCap: .round, lineJoin: .round))
                    .offset(y: config.lineWidth)

                SliderPath()
                    .trim(from: calculatePercentage(hour: minHour), to: calculatePercentage(hour: maxHour))
                    .stroke(STColor.cyan, style: StrokeStyle(lineWidth: config.lineWidth, lineCap: .round, lineJoin: .round))

                ZStack {
                    SliderHandle(hour: minHour, offset: translateHourToWidth(hour: minHour, reader: reader), diameter: config.handleDiameter) { value in
                        let newValue = min(translateWidthToHour(width: value.location.x, reader: reader), maxHour - config.minimumDistance)
                        if minHour != newValue {
                            minHour = newValue
                            feedbackGenerator.impactOccurred()
                        }
                    }

                    SliderHandle(hour: maxHour, offset: translateHourToWidth(hour: maxHour, reader: reader), diameter: config.handleDiameter) { value in
                        let newValue = max(translateWidthToHour(width: value.location.x, reader: reader), minHour + config.minimumDistance)
                        if maxHour != newValue {
                            maxHour = newValue
                            feedbackGenerator.impactOccurred()
                        }
                    }
                }
                .padding(.horizontal, -config.handleDiameter / 2)
            }
            .padding(.top, 10)
        }
        .padding(.horizontal, 5)
    }
}

struct TimeRangeSliderWrapper: View {
    @State private var minHour = 4
    @State private var maxHour = 18

    var config: TimeRangeSliderConfig {
        var config = TimeRangeSliderConfig()
        config.lineWidth = 20
        return config
    }

    var body: some View {
        VStack {
            TimeRangeSlider(minHour: $minHour, maxHour: $maxHour, config: config)
                .padding(.horizontal, 20)
        }
    }
}

struct TimeRangeSliderWrapper_Previews: PreviewProvider {
    static var previews: some View {
        TimeRangeSliderWrapper()
    }
}
