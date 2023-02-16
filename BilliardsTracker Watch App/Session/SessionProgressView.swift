//
//  SessionProgressView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-16.
//

import ComposableArchitecture
import SwiftUI

struct SessionProgressView: View {
    let store: StoreOf<Session>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                MarqueeText(viewStore.title, font: .headline)
                    .padding(.top)
                    .foregroundColor(.primaryElement)

                Spacer()

                HStack {
                    Button {

                    } label: {
                        Text("\(viewStore.potCount)")
                            .foregroundColor(.customGreen)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customGreen)

                    Button {

                    } label: {
                        Text("\(viewStore.missCount)")
                            .foregroundColor(.customRed)
                    }
                    .buttonStyle(.bordered)
                    .tint(.customRed)
                }
            }
        }
    }
}

// MARK: - Previews

struct SessionProgressView_Previews: PreviewProvider {
    static let store = Store(
        initialState: Session.State(title: "Preview", shotCount: 9),
        reducer: Session()
    )

    static var previews: some View {
        SessionProgressView(store: store)
    }
}
