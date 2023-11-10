//
//  ShotCountPicker.swift
//  BilliardsTrackerWatchApp
//
//  Created by Marius on 2023-11-10.
//

import ComposableArchitecture
import SwiftUI

struct ShotCountPicker: View {
    let store: StoreOf<SessionSetup>

    var body: some View {
        WithViewStore(store) { _ in
            VStack {
                Picker(selection: .constant(0)) {
                    ForEach(1..<101) { i in
                        Text("\(i)")
                            .font(.title2)
                            .tag(i)
                    }
                } label: {
                    Text("Shot Count")
                        .font(.headline)
                }

                Button("Done") {

                }
            }
        }
    }
}

#Preview {
    let store = Store(
        initialState: SessionSetup.State(),
        reducer: SessionSetup()
    )

    return ShotCountPicker(store: store)
        .foregroundStyle(Color.orange)
        .tint(Color.orange)
}
