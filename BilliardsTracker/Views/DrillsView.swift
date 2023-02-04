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

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                ForEach(viewStore.drills) { drill in
                    DrillView(store: store, drill: drill)
                        .padding([.horizontal], .drillViewPadding * 2)
                        .padding([.vertical], .drillViewPadding)
                        .transition(.slide)
                }
            }
        }
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

    init(store: StoreOf<DrillList>, drill: Drill) {
        self.store = store
        self.drill = drill
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ShrinkOnPressView {
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
                            Image(systemName: "xmark.seal")
                                .font(Font.title3.weight(.regular))
                                .imageScale(.small)
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
                .onTapGesture {
                    viewStore.send(.didTap(drill))
                }
            }
        }
    }
}

private extension DrillView {
    static let cornerRadius: CGFloat = 10
    static let iconsSpacing: CGFloat = 4
}
