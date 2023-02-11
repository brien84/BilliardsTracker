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
                        }

                        VStack(spacing: Self.iconsSpacing) {
                            Image(systemName: "repeat")
                                .font(Font.title3.weight(.regular))
                                .imageScale(.small)
                                .frame(maxHeight: .infinity, alignment: .top)
                                .foregroundColor(.customRed)
                                .hidden(!viewStore.drill.isContinuous)

                            Spacer()

                            Button {
                                viewStore.send(.didTapStatisticsButton)
                            } label: {
                                Image(systemName: "chart.bar.xaxis")
                                    .imageScale(.large)
                            }
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .foregroundColor(.customBlue)
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

// MARK: - Constants

private extension DrillItemView {
    static let cornerRadius: CGFloat = 10
    static let iconsSpacing: CGFloat = 4
}

// MARK: - Previews

struct DrillItemView_Previews: PreviewProvider {
    static let store = Store(
        initialState: DrillItem.State(drill: PersistenceClient.previewData.first!),
        reducer: DrillItem()
    )

    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            DrillItemView(store: store)
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
