//
//  SetupView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct SetupView: View {
    @EnvironmentObject var session: SessionManager

    @State private var attempts = 15

    var body: some View {
        if session.mode == .standalone {
            VStack {
                Text("Attempts")
                    .font(.footnote)

                Divider()

                Picker(selection: $attempts, label: EmptyView()) {
                    ForEach(1..<101, id: \.self) { i in
                        Text("\(i)")
                            .font(i == attempts ? .title2 : .title3)
                            .foregroundColor(i == attempts ? .primaryElement : .secondaryElement)
                    }
                }
                .borderHidden()

                Divider()

                Button("Start") {
                    session.setAttempts(attempts)
                    withAnimation {
                        session.isActive = true
                    }
                }
                .buttonStyle(BorderedButtonStyle(tint: .customBlue))
            }
        }

        if session.mode == .tracked {
            Text("Select a drill on BilliardsTracker iPhone app.")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundColor(.primaryElement)
        }
    }
}

private extension Picker {
    func borderHidden() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black, lineWidth: 5)
        )
    }
}

struct SetupViewStandalone_Previews: PreviewProvider {
    static var session: SessionManager = {
        let session = SessionManager()
        session.mode = .standalone
        return session
    }()

    static var previews: some View {
        SetupView()
            .environmentObject(session)
    }
}

struct SetupViewTracked_Previews: PreviewProvider {
    static var session: SessionManager = {
        let session = SessionManager()
        session.mode = .tracked
        return session
    }()

    static var previews: some View {
        SetupView()
            .environmentObject(session)
    }
}
