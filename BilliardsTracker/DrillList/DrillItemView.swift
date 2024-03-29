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
                        ZStack {
                            Text("100")
                                .opacity(.zero)
                            Text("\(viewStore.drill.shotCount)")
                        }
                        .font(.title.weight(.semibold))
                        .foregroundColor(.primaryElement)
                        .padding(.horizontal)

                        Text(viewStore.drill.title.uppercased())
                            .font(.headline.bold())
                            .foregroundColor(.secondaryElement)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding()

                        VStack(spacing: Self.iconsSpacing) {
                            Image(systemName: "repeat")
                                .font(.title3.weight(.bold))
                                .foregroundColor(.customGreen)
                                .imageScale(.small)
                                .opacity(viewStore.drill.isContinuous ? 1 : 0)

                            Button {
                                viewStore.send(.didPressDrillLogButton)
                            } label: {
                                Image(systemName: "chart.bar.xaxis")
                                    .foregroundColor(.customBlue)
                                    .imageScale(.large)
                            }
                            .accessibilityLabel("Open Drill Log")
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
    static let iconsSpacing: CGFloat = 16
}

// MARK: - Previews

struct DrillItemView_Previews: PreviewProvider {
    static let store = Store(
        initialState: DrillItem.State(drill: PersistenceClient.mockDrill),
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
