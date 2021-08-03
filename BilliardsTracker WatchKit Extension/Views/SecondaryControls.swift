//
//  SecondaryControls.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct SecondaryControls: View {
    @EnvironmentObject var session: SessionManager

    @Binding var currentTab: Int

    var body: some View {
        VStack {
            HStack {
                SecondaryControlButton(title: "Stop", imageName: "multiply", color: .customRed) {
                    session.isActive = false
                    currentTab = 0
                }

                SecondaryControlButton(title: "Undo", imageName: "arrow.uturn.backward", color: .customBlue) {
                    session.undo()
                    currentTab = 0
                }
                .disabled(session.didPotLastAttempt == nil)
            }

            HStack {
                SecondaryControlButton(title: "Pause", imageName: "pause", color: .customYellow) {
                    session.isPaused = true
                    currentTab = 0
                }
                .disabled(session.isPaused)

                SecondaryControlButton(title: "Resume", imageName: "play", color: .customGreen) {
                    session.isPaused = false
                    currentTab = 0
                }
                .disabled(!session.isPaused)
            }
        }
    }
}

private struct SecondaryControlButton: View {
    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let imageName: String
    private let color: Color
    private let action: () -> Void

    init(title: String, imageName: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.imageName = imageName
        self.color = color
        self.action = action
    }

    var body: some View {
        VStack {
            Button {
                withAnimation { action() }
            } label: {
                Image(systemName: imageName)
                    .frame(width: 25, height: 25)
                    .font(Font.title2.weight(.semibold))
                    .foregroundColor(color)
                    .padding()
            }
            .buttonStyle(BorderedButtonStyle(tint: color))

            Text(title)
                .font(.footnote)
                .foregroundColor(isEnabled ? .primaryElement : .secondaryElement)
        }
    }
}

struct SecondaryControls_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryControls(currentTab: .constant(1))
            .environmentObject(SessionManager())
    }
}
