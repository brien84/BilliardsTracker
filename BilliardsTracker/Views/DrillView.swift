//
//  DrillView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-04-19.
//

import SwiftUI

struct DrillView: View {
    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var store: StoreManager

    private let drill: Drill

    @State private var touchesBegan = false

    init(drill: Drill) {
        self.drill = drill
    }

    var body: some View {
        let navigationBinding = Binding<Bool>(
                                    get: { session.runState == .running && session.selectedDrill == drill },
                                    set: { session.runState = $0 ? .running : .stopped }
                                ).removeDuplictates()

        ZStack {
            NavigationLink(
                destination: EmptyView(),
                label: { EmptyView() }
            )

            NavigationLink(
                destination: SessionView(drill: drill, startDate: session.startDate),
                isActive: navigationBinding,
                label: { EmptyView() }
            ).disabled(true)

            Color.secondaryBackground

            HStack(spacing: .zero) {
                if drill.attempts > 0 {
                    ZStack {
                        Text("100").opacity(0)
                        Text("\(drill.attempts)")
                            .accessibility(identifier: "drillView_attemptsText")
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal)
                    .font(Font.title.weight(.semibold))
                    .foregroundColor(.primaryElement)
                }

                if !drill.title.isEmpty {
                    Text(drill.title.uppercased())
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding()
                        .font(Font.headline.weight(.bold))
                        .foregroundColor(.secondaryElement)
                        .accessibility(identifier: "drillView_titleText")
                }

                VStack(spacing: .iconsSpacing) {
                    failableIcon
                        .frame(maxHeight: .infinity, alignment: .top)
                        .foregroundColor(.customRed)
                        .hidden(!drill.isFailable)

                    Spacer()

                    statisticsButton
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .foregroundColor(.customBlue)
                }
                .padding()
            }
        }
        .cornerRadius(.cornerRadius)
        .scaleEffect(touchesBegan ? .scaleEffectOn : .scaleEffectOff)
        .onTapGesture {
            session.start(drill: drill)
        }
        .onLongPressGesture(minimumDuration: .scaleGestureDuration, maximumDistance: .scaleGestureDistance) { isPressing in
            withAnimation(.easeOut(duration: .scaleAnimationDuration)) {
                touchesBegan = isPressing
            }
        } perform: { }
    }

    private var failableIcon: some View {
        Image(systemName: "xmark.seal")
            .font(Font.title3.weight(.regular))
            .imageScale(.small)
            .accessibility(identifier: "drillView_failableIcon")
    }

    private var statisticsButton: some View {
        NavigationLink(
            destination: StatisticsView(drill: drill),
            label: {
                Image(systemName: "chart.bar.xaxis")
                    .imageScale(.large)
            }
        )
        .accessibility(identifier: "drillView_statisticsButton")
    }
}

private extension CGFloat {
    static var cornerRadius: CGFloat {
        10
    }

    static var iconsSpacing: CGFloat {
        4
    }

    static var scaleEffectOn: CGFloat {
        0.95
    }

    static var scaleEffectOff: CGFloat {
        1.0
    }

    static var scaleGestureDistance: CGFloat {
        1.0
    }
}

private extension Double {
    static var scaleAnimationDuration: Double {
        0.15
    }

    static var scaleGestureDuration: Double {
        0.8
    }
}

// swiftlint:disable force_try
struct DrillView_Previews: PreviewProvider {
    static var drillStore = try! DrillStore(inMemory: true, isPreview: true)
    static var session = SessionManager(store: drillStore)
    static var store = StoreManager(store: drillStore)
    static var drill = store.drills.first!

    static var view: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            DrillView(drill: drill)
                .environmentObject(session)
                .environmentObject(store)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
