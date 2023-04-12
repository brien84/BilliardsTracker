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
                        .font(.headline)
                        .foregroundColor(.primaryElement)
                        .padding(.top)

                    Spacer()

                    Divider()

                    HStack {
                        Text("\(viewStore.potCount)")
                            .foregroundColor(.customGreen)
                            .frame(maxWidth: .infinity)

                        Text("\(viewStore.missCount)")
                            .foregroundColor(.customRed)
                            .frame(maxWidth: .infinity)
                    }
                    .font(.title2.weight(.medium))

                    Divider()

                    Spacer()

                    HStack {
                        ResultButton(imageName: "checkmark") {
                            viewStore.send(.doneButtonDidTap, animation: .default)
                        }
                        .tint(.customGreen)

                        ResultButton(imageName: "arrow.counterclockwise") {
                            viewStore.send(.restartButtonDidTap, animation: .default)
                        }
                        .tint(.customBlue)
                    }
                }
            }
        }
    }
}

private struct ResultButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: imageName)
                .font(.title3.weight(.bold))
        }
        .buttonStyle(.bordered)
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
