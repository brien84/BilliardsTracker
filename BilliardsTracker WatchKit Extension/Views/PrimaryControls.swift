//
//  PrimaryControls.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-02.
//

import SwiftUI

struct PrimaryControls: View {
    @EnvironmentObject var session: SessionManager

    var body: some View {
        VStack {
            Text(session.title ?? "Standalone")
                .padding(.top)
                .font(.headline)
                .foregroundColor(.primaryElement)

            Spacer()

            HStack {
                Button {
                    withAnimation {
                        session.addAttempt(isSuccess: true)
                    }
                } label: {
                    Text("\(session.potCount)")
                        .foregroundColor(.customGreen)
                }
                .buttonStyle(BorderedButtonStyle(tint: .customGreen))

                Button {
                    withAnimation {
                        session.addAttempt(isSuccess: false)
                    }
                } label: {
                    Text("\(session.missCount)")
                        .foregroundColor(.customRed)
                }
                .buttonStyle(BorderedButtonStyle(tint: .customRed))
            }
            .disabled(session.isPaused)

        }
    }
}

struct PrimaryControls_Previews: PreviewProvider {
    static var session: SessionManager = {
        let session = SessionManager()
        session.setAttempts(69)
        return session
    }()

    static var previews: some View {
        PrimaryControls()
            .environmentObject(session)
    }
}
