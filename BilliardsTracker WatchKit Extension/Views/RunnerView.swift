//
//  RunnerView.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-10.
//

import SwiftUI


struct RunnerView: View {
    @EnvironmentObject var runner: DrillRunner

    private var mode: Mode

    @State private var currentTab: Int = 0

    init(_ mode: Mode) {
        self.mode = mode
    }

    var body: some View {
        Group {
            if runner.isActive {
                Group {
                    if runner.isCompleted {
                        CompletionView()
                    } else {
                        TabView(selection: $currentTab) {
                            PrimaryControls().tag(0)
                            SecondaryControls().tag(1)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
            } else {
                SetupView()
                    .navigationBarBackButtonHidden(false)
            }
        }
        .onAppear {
            runner.mode = mode
        }
        .onDisappear {
            runner.mode = nil
        }
    }
}

struct RunnerView_Previews: PreviewProvider {
    static var previews: some View {
        RunnerView(.tracked)
            .environmentObject(DrillRunner())
    }
}
