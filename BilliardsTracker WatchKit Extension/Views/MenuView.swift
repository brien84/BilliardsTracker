//
//  MenuView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-10.
//

import SwiftUI

struct MenuView: View {
    @State private var currentTab: Int = 0

    var body: some View {
        TabView(selection: $currentTab) {

            MenuOption(title: "Standalone", destination: AnyView(RunnerView(.standalone)))
                .foregroundColor(.customGreen)
                .tag(0)

            MenuOption(title: "Tracked", destination: AnyView(RunnerView(.tracked)))
                .foregroundColor(.customRed)
                .tag(1)

        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct MenuOption: View {
    private var title: String
    private var destination: AnyView

    init(title: String, destination: AnyView) {
        self.title = title
        self.destination = destination
    }

    @State private var scale: CGFloat = 1.0

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.title3)
        }
        .scaleEffect(scale)
        .onAppear {
            let animation = Animation.easeInOut(duration: .animationDuration)

            withAnimation(animation.repeatForever(autoreverses: true)) {
                scale = .animationScaleValue
            }
        }
    }

}

private extension Double {
    static var animationDuration: Double {
        1.0
    }
}

private extension CGFloat {
    static var animationScaleValue: CGFloat {
        0.85
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
