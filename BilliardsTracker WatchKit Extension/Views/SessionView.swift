//
//  SessionView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-10.
//

import SwiftUI

struct SessionView: View {
    @EnvironmentObject var session: SessionManager

    @State private var currentTab: Int = 0

    private var mode: Mode

    init(_ mode: Mode) {
        self.mode = mode
    }

    var body: some View {
        Group {
            if session.isActive {
                Group {
                    if session.isCompleted {
                        CompletionView()
                            .transition(.move(edge: .bottom))
                    } else {
                        TabView(selection: $currentTab) {
                            PrimaryControls().tag(0)
                            SecondaryControls(currentTab: $currentTab).tag(1)
                        }
                        .transition(.slide)
                        .onAppear {
                            currentTab = 0
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
            } else {
                SetupView()
                    .transition(.move(edge: .bottom))
                    .navigationBarBackButtonHidden(false)
            }
        }
        .onAppear {
            session.mode = mode
        }
        .onDisappear {
            session.mode = nil
        }
    }
}

struct SessionView_Previews: PreviewProvider {
    static var session: SessionManager = {
        let session = SessionManager()
        session.isActive = true
        return session
    }()

    static var previews: some View {
        SessionView(.standalone)
            .environmentObject(session)
    }
}
