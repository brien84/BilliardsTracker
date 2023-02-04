//
//  DrillListView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-03-31.
//

import ComposableArchitecture
import SwiftUI

struct DrillListView: View {
    let store: StoreOf<DrillList>

    var body: some View {
        WithViewStore(store) { _ in
            ScrollView {
                LazyVStack(spacing: Self.verticalSpacing) {
                    ForEachStore(
                        store.scope(state: \.drillItems, action: DrillList.Action.drillItem(id:action:))
                    ) {
                        DrillItemView(store: $0)
                            .padding(.horizontal)
                            .transition(.slide)
                    }
                }
            }
        }
    }
}

private extension DrillListView {
    static let verticalSpacing: CGFloat = 16
}
