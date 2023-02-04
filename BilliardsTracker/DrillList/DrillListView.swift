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
