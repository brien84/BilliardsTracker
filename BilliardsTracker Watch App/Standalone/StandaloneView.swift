//
//  StandaloneView.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-19.
//

import ComposableArchitecture
import SwiftUI

struct StandaloneView: View {
    let store: StoreOf<Standalone>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                VStack {
                    Text("Shots")
                        .font(.footnote)

                    Divider()

                    Picker("Set shot count",
                        selection: viewStore.binding(
                            get: \.shotCount,
                            send: Standalone.Action.shotCountDidChange
                        )
                    ) {
                        ForEach(1..<101) { i in
                            Text("\(i)")
                                .tag(i)
                                .font(i == viewStore.shotCount ? .title2 : .title3)
                                .foregroundColor(i == viewStore.shotCount ? .primaryElement : .secondaryElement)
                        }
                    }
                    .borderHidden()
                    .labelsHidden()

                    Divider()

                    Button("Start") {

                    }
                    .buttonStyle(.bordered)
                    .tint(.customBlue)
                }
            }
        }
    }
}

private extension Picker {
    func borderHidden() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 5)
        )
    }
}

// MARK: - Previews

struct StandaloneView_Previews: PreviewProvider {
    static var previews: some View {
        StandaloneView(store: Store(initialState: Standalone.State(), reducer: Standalone()))
    }
}
