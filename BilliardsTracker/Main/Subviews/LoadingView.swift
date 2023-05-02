//
//  LoadingView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-17.
//

import SwiftUI

struct LoadingView: View {
    @State private var degrees = Angle.degrees(.zero)

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(Self.backgroundOpacity)

            Image("loading")
                .resizable()
                .frame(width: Self.imageSize.width, height: Self.imageSize.height)
                .rotationEffect(degrees)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: Self.animationDuration)
                .repeatForever(autoreverses: false)
            ) {
                degrees = .degrees(360)
            }
        }
    }
}

// MARK: - Constants

private extension LoadingView {
    static let animationDuration: CGFloat = 0.95
    static let backgroundOpacity: CGFloat = 0.5
    static let imageSize: CGSize = CGSize(width: 44, height: 44)
}

// MARK: - Previews

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.green
                .ignoresSafeArea()

            LoadingView()
        }
    }
}
