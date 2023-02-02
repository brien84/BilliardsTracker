//
//  DrillsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import ComposableArchitecture
import SwiftUI

struct DrillsView: View {
    let store: StoreOf<DrillList>

    init(store: StoreOf<DrillList>) {
        self.store = store
    }

    private var isBlurred = false

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                ForEach(viewStore.drills) { drill in
                    DrillView(store: store, drill: drill)
                        .padding([.horizontal], .drillViewPadding * 2)
                        .padding([.vertical], .drillViewPadding)
                        .transition(.slide)
                }
                .blur(radius: isBlurred ? .blurValue : 0)
            }
        }
    }

    /// Applies blur effect to `DrillsView`.
    /// This function is required, since applying blur directly on `ScrollView` causes `NavigationView` layout bug.
    func blur(_ isEnabled: Bool) -> some View {
        var view = self
        view.isBlurred = isEnabled
        return view
    }
}

private extension CGFloat {
    static var drillViewPadding: CGFloat {
        8
    }

    static var blurValue: CGFloat {
        5
    }
}

struct DrillView: View {
    let store: StoreOf<DrillList>

    private let drill: Drill

    @State private var touchesBegan = false

    init(store: StoreOf<DrillList>, drill: Drill) {
        self.store = store
        self.drill = drill
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
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

                    VStack(spacing: Self.iconsSpacing) {
                        failableIcon
                            .frame(maxHeight: .infinity, alignment: .top)
                            .foregroundColor(.customRed)
                            .hidden(!drill.isFailable)

                        Spacer()

                        Button {
                            viewStore.send(.didTapStatisticsButton(drill))
                        } label: {
                            Image(systemName: "chart.bar.xaxis")
                                .imageScale(.large)
                        }
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .foregroundColor(.customBlue)
                        .accessibility(identifier: "drillView_statisticsButton")
                    }
                    .padding()
                }
            }
            .cornerRadius(Self.cornerRadius)
            .scaleEffect(touchesBegan ? Self.scaleEffectOn : Self.scaleEffectOff)
            .onTapGesture {
                viewStore.send(.didTap(drill))
            }
            .onLongPressGesture(minimumDuration: Self.scaleGestureDuration, maximumDistance: Self.scaleGestureDistance) { isPressing in
                withAnimation(.easeOut(duration: Self.scaleAnimationDuration)) {
                    touchesBegan = isPressing
                }
            } perform: { }
        }
    }

    private var failableIcon: some View {
        Image(systemName: "xmark.seal")
            .font(Font.title3.weight(.regular))
            .imageScale(.small)
            .accessibility(identifier: "drillView_failableIcon")
    }
}

private extension DrillView {
    static let cornerRadius: CGFloat = 10
    static let iconsSpacing: CGFloat = 4
    static let scaleEffectOn: CGFloat = 0.9
    static let scaleEffectOff: CGFloat = 1.0
    static let scaleGestureDistance: CGFloat = 1.0
    static let scaleAnimationDuration: Double = 0.1
    static let scaleGestureDuration: Double = 0.8
}

// struct DrillsView_Previews: PreviewProvider {
//     static var drillStore = try! DrillStore(inMemory: true, isPreview: true)
//     static var session = SessionManager(store: drillStore)
//     static var store = StoreManager(store: drillStore)
//
//     static var view: some View {
//         ZStack {
//             Color.primaryBackground
//                 .ignoresSafeArea()
//
//             DrillsView()
//                 .environmentObject(session)
//                 .environmentObject(store)
//         }
//     }
//
//     static var previews: some View {
//         view.preferredColorScheme(.light)
//         view.preferredColorScheme(.dark)
//     }
// }
