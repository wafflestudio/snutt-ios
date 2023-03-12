//
//  TimeRangeSlider.swift
//  SNUTT
//
//  Created by user on 2023/03/10.
//

import SwiftUI



struct TimeRangeSlider: View {
    @Binding var minHour: Int
    @Binding var maxHour: Int
    @GestureState private var isDraggingMinSlider = false
    @GestureState private var isDraggingMaxSlider = false

    let lineWidth: CGFloat = 5
    static let tickCount = 24

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
        func path(in rect: CGRect) -> Path {
            let width = rect.size.width
            let centerY = rect.size.height / 2
            let tickCount = TimeRangeSlider.tickCount
            return Path { path in
                for i in 0 ... tickCount {
                    let x: Double = Double(i)*width / Double(tickCount)
                    let y: Double = i % 6 == 0 ? 5 : 2
                    path.move(to: CGPoint(x: x, y: centerY))
                    path.addLine(to: .init(x: x, y: centerY + y))
                }
            }
        }
    }

    struct SliderKnob: View {
        let hour: Int
        let offset: CGFloat
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
                .onChanged({ value in
                    onChanged(value)
                })
            // Combine two gestures with different minimumDistance
            // to prevent jumps when pressed
            return draggingGesture.simultaneously(with: initialGesture)
        }

        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 20)
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
            }
            .animation(.customSpring, value: isDragging)
        }
    }

    func translateHourToWidth(hour: Int, reader: GeometryProxy) -> CGFloat {
        return CGFloat(hour) * reader.size.width / CGFloat(TimeRangeSlider.tickCount)
    }

    func translateWidthToHour(width: CGFloat, reader: GeometryProxy) -> Int {
        let normalizedWidth = max(min(width / reader.size.width, 1.0), 0.0)
        let hour = Int(round(Double(normalizedWidth) * Double(TimeRangeSlider.tickCount)))
        return hour
    }

    func calculatePercentage(hour: Int) -> Double {
        return Double(hour) / Double(TimeRangeSlider.tickCount)
    }

    var body: some View {
        GeometryReader { reader in
            ZStack(alignment: .leading) {
                SliderPath()
                    .stroke(Color(uiColor: .quaternaryLabel).opacity(0.5), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

                TickMarks()
                    .stroke(Color(uiColor: .quaternaryLabel).opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .offset(y: lineWidth)

                SliderPath()
                    .trim(from: calculatePercentage(hour: minHour), to: calculatePercentage(hour: maxHour))
                    .stroke(STColor.cyan, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

                ZStack {
                    SliderKnob(hour: minHour, offset: translateHourToWidth(hour: minHour, reader: reader)) { value in
                        minHour = min(translateWidthToHour(width: value.location.x, reader: reader), maxHour - 6)
                    }

                    SliderKnob(hour: maxHour, offset: translateHourToWidth(hour: maxHour, reader: reader)) { value in
                        maxHour = max(translateWidthToHour(width: value.location.x, reader: reader), minHour + 6)
                    }
                }
                .padding(.horizontal, -10)
            }
            .padding(.top, 10)
        }
    }
}

struct TimeRangeSliderWrapper: View {
    @State private var minHour = 4
    @State private var maxHour = 18

    var body: some View {
        VStack {
            TimeRangeSlider(minHour: $minHour, maxHour: $maxHour)
                .padding(.horizontal, 20)
        }
    }
}

struct TimeRangeSliderWrapper_Previews: PreviewProvider {
    static var previews: some View {
        TimeRangeSliderWrapper()
    }
}
