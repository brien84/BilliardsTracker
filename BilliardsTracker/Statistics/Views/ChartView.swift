//
//  ChartView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-05-03.
//

import SwiftUI

struct ChartView: View {
    private let dataPoints: [CGFloat]
    private let maxValue: Int

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ForEach(calculateLabelValues(in: proxy.size), id: \.self) { value in
                    ChartLabel(value: value)
                        .offset(calculateOffset(for: value, in: proxy.size.height))
                }
            }

            ChartLine(dataPoints: dataPoints)
                .stroke(
                    Color.customBlue,
                    style: StrokeStyle(lineWidth: Self.lineWidth(for: dataPoints.count), lineCap: .round, lineJoin: .round)
                )
                .padding(.leading, Self.leadingPadding)
        }
    }

    init(dataPoints: [CGFloat], maxValue: Int) {
        self.dataPoints = dataPoints
        self.maxValue = maxValue
    }

    private func calculateOffset(for label: Int, in height: CGFloat) -> CGSize {
        guard maxValue > 0 else { return .zero }

        let height = height * (1 - CGFloat(label) / CGFloat(maxValue))

        return CGSize(width: 0, height: height - Self.labelHeight / 2)
    }

    private func calculateLabelValues(in size: CGSize) -> [Int] {
        let values = Array(0...maxValue)
        let maxLabelCount = Int(size.height / (2 * Self.labelHeight))

        if maxValue <= maxLabelCount {
            return values
        } else {
            return reduce(labelValues: values, maxLabelCount: maxLabelCount)
        }
    }

    private func reduce(labelValues values: [Int], maxLabelCount: Int) -> [Int] {
        let reduced = stride(from: 0, to: values.count, by: 2).map { i in
            // Reverse `values` to ensure highest value is not removed.
            values.reversed()[i]
        }

        if reduced.count <= maxLabelCount {
            return reduced.reversed()
        } else {
            return reduce(labelValues: reduced.reversed(), maxLabelCount: maxLabelCount)
        }
    }
}

private struct ChartLine: Shape {
    var dataPoints: [CGFloat]

    func path(in rect: CGRect) -> Path {
        func point(at ix: Int) -> CGPoint {
            let point = dataPoints[ix]
            let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
            let y = (1 - point) * rect.height

            return CGPoint(x: x, y: y)
        }

        return Path { path in
            guard dataPoints.count > 1 else { return }

            let start = dataPoints[0]
            path.move(to: CGPoint(x: 0, y: (1 - start) * rect.height))

            for idx in dataPoints.indices {
                path.addLine(to: point(at: idx))
            }
        }
    }
}

private struct ChartLabel: View {
    var value: Int

    var body: some View {
        HStack {
            ZStack {
                Text("100")
                    .opacity(0)
                Text("\(value)")
            }
            .font(.caption.bold())
            .foregroundColor(.primaryElement)

            ChartLabelLine()
                .stroke(
                    Color.secondaryElement,
                    style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [5, 10])
                )
                .frame(height: 1)
                .offset(x: 0, y: 0.5)
        }
    }

    struct ChartLabelLine: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            }
        }
    }
}

// MARK: - Constants

private extension ChartView {
    static var labelHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .caption1).lineHeight
    }

    static let leadingPadding: CGFloat = 32

    static func lineWidth(for dataPointsCount: Int) -> CGFloat {
        5 - 0.04 * CGFloat(dataPointsCount)
    }
}

// MARK: - Previews

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ChartView(dataPoints: [0, 0.5, 0.3, 1, 0.75, 0.66], maxValue: 100)
                .aspectRatio(1, contentMode: .fit)
                .padding()
        }
    }
}
