//
//  ChartView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-05-03.
//

import SwiftUI

struct ChartView: View {
    private let maxValue: Int
    private let dataPoints: [CGFloat]

    private let labelHeight = UIFont.preferredFont(forTextStyle: .caption1).lineHeight

    @State private var isReady = false

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                ForEach(isReady ? calculateLabelValues(in: proxy.size) : [], id: \.self) { i in
                    ChartLabel(value: i)
                        .offset(x: 0, y: proxy.size.height * (1 - CGFloat(i) / CGFloat(maxValue)))
                        .offset(x: 0, y: -labelHeight / 2)
                }
            }

            Chart(dataPoints: dataPoints)
                .stroke(Color.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                .padding(.leading, 30)
        }
        .onAppear {
            isReady = true
        }
    }

    init(dataPoints: [CGFloat], maxValue: Int) {
        self.dataPoints = dataPoints
        self.maxValue = maxValue
    }

    private func calculateLabelValues(in size: CGSize) -> [Int] {
        let maxLabelCount = Int(size.height / (2 * labelHeight))

        let values = Array(0...maxValue)

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

struct ChartView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))
    static var drill = manager.drills.first!
    static var statistics = StatisticsManager(drill: drill)

    static var view: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            ChartView(dataPoints: statistics.chartDataPoints, maxValue: statistics.drill.attempts)
                .aspectRatio(1, contentMode: .fit)
                .padding()
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}

private struct Chart: Shape {
    var dataPoints: [CGFloat]

    func path(in rect: CGRect) -> Path {
        func point(at ix: Int) -> CGPoint {
            let point = dataPoints[ix]
            let x = rect.width * CGFloat(ix) / CGFloat(dataPoints.count - 1)
            let y = (1 - point) * rect.height

            return CGPoint(x: x, y: y)
        }

        return Path { p in
            guard dataPoints.count > 1 else { return }

            let start = dataPoints[0]
            p.move(to: CGPoint(x: 0, y: (1 - start) * rect.height))

            for idx in dataPoints.indices {
                p.addLine(to: point(at: idx))
            }
        }
    }
}

private struct ChartLabel: View {
    var value: Int

    var body: some View {
        HStack {
            ZStack {
                Text("100").hidden()
                Text("\(value)")
            }
            .font(Font.caption.bold())
            .foregroundColor(.primaryElement)

            Line()
                .stroke(Color.secondaryElement, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [5, 10]))
                .frame(height: 1)
                .offset(x: 0, y: 0.5)
        }
    }

    struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: rect.maxX, y: 0))
            }
        }
    }
}
