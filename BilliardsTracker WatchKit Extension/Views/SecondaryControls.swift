//
//  SecondaryControls.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct SecondaryControls: View {
    @EnvironmentObject var runner: DrillRunner

    var body: some View {
        EmptyView()
    }
}

struct SecondaryControls_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryControls()
            .environmentObject(DrillRunner())
    }
}
