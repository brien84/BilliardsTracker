//
//  ResultView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-03-06.
//

import ComposableArchitecture
import SwiftUI

struct ResultView: View {
    let store: StoreOf<Result>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                Color.black

                VStack {
                    Text("Completed!")
                        .padding(.top)
                        .font(.headline)
                        .foregroundColor(.primaryElement)

                    Spacer()

                    Divider()

                    HStack {
                        Text("\(viewStore.potCount)")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.customGreen)

                        Text("\(viewStore.missCount)")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.customRed)
                    }
                    .font(.title2)

                    Divider()
                }
            }
        }
    }
}

// MARK: - Previews

struct ResultView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Result.State(potCount: 9, missCount: 9),
        reducer: Result()
    )

    static var previews: some View {
        ResultView(store: store)
    }
}
