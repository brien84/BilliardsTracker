//
//  CompletionView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct CompletionView: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {

        VStack {
            Text("Completed!")
                .padding(.top)
                .font(.headline)
                .foregroundColor(.primaryElement)

            Spacer()

            HStack {
                Text("\(session.potCount)")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.customGreen)

                Text("\(session.missCount)")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.customRed)
            }
            .font(.title2)

            Spacer()

            HStack {
                CompletionViewButton(imageName: "checkmark", color: .customGreen) {
                    session.isActive = false
                }

                CompletionViewButton(imageName: "arrow.counterclockwise", color: .customBlue) {
                    session.isActive = true
                }
            }
        }

    }
}

private struct CompletionViewButton: View {
    private let imageName: String
    private let color: Color
    private let action: () -> Void

    init(imageName: String, color: Color, action: @escaping () -> Void) {
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
                    .font(Font.title3.weight(.semibold))
            }
            .buttonStyle(BorderedButtonStyle(tint: color))
        }
    }
}

struct CompletionView_Previews: PreviewProvider {
    static var previews: some View {
        CompletionView()
            .environmentObject(SessionManager())
    }
}
