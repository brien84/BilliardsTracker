//
//  SecondaryControls.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct SecondaryControls: View {
    @EnvironmentObject var runner: SessionManager

    var body: some View {
        VStack {
            HStack {
                SecondaryControlButton(title: "Stop", imageName: "multiply", color: .customRed) {
                    runner.isActive = false
                }

                SecondaryControlButton(title: "Undo", imageName: "arrow.uturn.backward", color: .customBlue) {
                    runner.undo()
                }
                .disabled(runner.didPotLastAttempt == nil)
            }

            HStack {
                SecondaryControlButton(title: "Pause", imageName: "pause", color: .customYellow) {
                    runner.isPaused = true
                }
                .disabled(runner.isPaused)

                SecondaryControlButton(title: "Resume", imageName: "play", color: .customGreen) {
                    runner.isPaused = false
                }
                .disabled(!runner.isPaused)
            }
            
        }
    }
}

private struct SecondaryControlButton: View {
    @Environment(\.isEnabled) private var isEnabled

    private let title: String
    private let imageName: String
    private let color: Color
    private let action: () -> ()

    init(title: String, imageName: String, color: Color, action: @escaping () -> ()) {
        self.title = title
        self.imageName = imageName
        self.color = color
        self.action = action
    }

    var body: some View {
        VStack {
            Button {
                action()
            } label: {
                Image(systemName: imageName)
                    .frame(width: 25, height: 25)
                    .font(Font.title2.weight(.semibold))
                    .foregroundColor(color)
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
        SecondaryControls()
            .environmentObject(SessionManager())
    }
}
