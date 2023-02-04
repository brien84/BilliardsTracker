//
//  DrillItemView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-02-04.
//

import ComposableArchitecture
import SwiftUI

struct DrillItemView: View {
    let store: StoreOf<DrillItem>

    var body: some View {
        WithViewStore(store) { viewStore in
            ShrinkOnPressView {
                ZStack {
                    Color.secondaryBackground

                    HStack(spacing: .zero) {
                        if viewStore.drill.attempts > 0 {
                            ZStack {
                                Text("100").opacity(0)
                                Text("\(viewStore.drill.attempts)")
                                    .accessibility(identifier: "drillView_attemptsText")
                            }
                            .frame(maxHeight: .infinity)
                            .padding(.horizontal)
                            .font(Font.title.weight(.semibold))
                            .foregroundColor(.primaryElement)
                        }

                        if !viewStore.drill.title.isEmpty {
                            Text(viewStore.drill.title.uppercased())
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
                                .hidden(!viewStore.drill.isFailable)

                            Spacer()

                            Button {
                                viewStore.send(.didTapStatisticsButton)
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
                    viewStore.send(.didSelectDrill)
                }
            }
        }
    }
}

private extension DrillItemView {
    static let cornerRadius: CGFloat = 10
    static let iconsSpacing: CGFloat = 4
}
