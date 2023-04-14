//
//  OnboardView.swift
//  BilliardsTracker
//
//  Created by Marius on 2023-04-08.
//

import SwiftUI

struct OnboardView: View {
    let buttonAction: () -> Void

    var body: some View {
        GeometryReader { proxy in
            VStack {
                TitleView()
                    .position(
                        x: proxy.frame(in: .global).midX,
                        y: proxy.frame(in: .global).maxY * Self.titleYPositionModifier
                    )

                Spacer()

                VStack {
                    WarningView()

                    FullWidthButtonView(text: "Continue") {
                        buttonAction()
                    }
                    .foregroundColor(.customBlue)
                }
                .padding(.horizontal, Self.horizontalPadding)
                .padding(.vertical, Self.verticalPadding)
            }
        }
        .background(Color.secondaryBackground)
    }
}

private struct TitleView: View {
    var body: some View {
        VStack {
            Image("chalk")
                .shadow(color: .black, radius: Self.shadowRadius)

            Text("Welcome to BilliardsTracker")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
        }
    }
}

private struct WarningView: View {
    var body: some View {
        HStack {
            Image(systemName: "applewatch")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: Self.iconSize.width, height: Self.iconSize.height)

            Text("Please note that Apple Watch is required to use this application")
                .font(.headline)
                .foregroundColor(.primaryElement)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(Self.padding)
    }
}

// MARK: - Constants

private extension OnboardView {
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 32
    static let titleYPositionModifier: CGFloat = 0.35
}

private extension TitleView {
    static let shadowRadius: CGFloat = 4
}

private extension WarningView {
    static let iconSize: CGSize = CGSize(width: 50, height: 50)
    static let padding: CGFloat = 16
}

// MARK: - Previews

struct OnboardView_Previews: PreviewProvider {
    static var previews: some View {
        Color.green
            .ignoresSafeArea()
            .sheet(isPresented: .constant(true)) {
                OnboardView { }
            }
    }
}
