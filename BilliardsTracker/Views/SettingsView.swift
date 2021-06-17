//
//  SettingsView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-13.
//

import SwiftUI

struct SettingsView: View {
    @Binding var isShowingSettings: Bool

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.primaryBackground
                    .edgesIgnoringSafeArea(.bottom)

            }
            .frame(width: proxy.size.width * .widthModifier)
        }
    }

}

private extension CGFloat {
    static var widthModifier: CGFloat {
        0.75
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var view: some View {
        ZStack {
            Color.secondaryBackground
                .ignoresSafeArea()

            SettingsView(isShowingSettings: .constant(true))
        }
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
