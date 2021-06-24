//
//  MainView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-14.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var manager: DrillManager

    @State private var isCreatingDrill = false
    @State private var isShowingSettings = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.primaryBackground
                    .ignoresSafeArea()

                DrillsView()
                    .blur(isShowingSettings)
                    .disabled(isShowingSettings)

                createDrillBackgroundButton
                    .opacity(manager.drills.count == 0 ? 1 : 0)

                SettingsView(isShowingSettings: $isShowingSettings)
                    .offset(isShowingSettings ? .zero : .settingsViewHiddenOffset)
            }
            .navigationBarTitle("Drills")
            .navigationBarItems(leading: settingsButton, trailing: createDrillButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $isCreatingDrill) {
            CreateDrillView(isCreatingDrill: $isCreatingDrill)
        }
    }

    private var settingsButton: some View {
        Button(
            action: {
                withAnimation(.spring()) {
                    isShowingSettings.toggle()
                }
            },
            label: {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.large)
            }
        )
    }

    private var createDrillButton: some View {
        Button(
            action: {
                isCreatingDrill = true
            },
            label: {
                Image(systemName: "plus")
                    .imageScale(.large)
            }
        )
        .disabled(isShowingSettings)
    }

    private var createDrillBackgroundButton: some View {
        Button(
            action: {
                isCreatingDrill = true
            },
            label: {
                VStack {
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .imageScale(.large)
                        .scaleEffect(.createDrillBackgroundButtonImageScale)

                    Text("Create drill")
                        .font(.title)
                        .padding(.createDrillBackgroundButtonTextPadding)
                }
            }
        )
        .foregroundColor(.primaryElement)
    }
}

private extension CGFloat {
    static var createDrillBackgroundButtonImageScale: CGFloat {
        2.0
    }

    static var createDrillBackgroundButtonTextPadding: CGFloat {
        32
    }
}

private extension CGSize {
    static var settingsViewHiddenOffset: CGSize {
        CGSize(width: -500, height: 0)
    }
}

struct MainView_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true, isPreview: true))

    static var view: some View {
        MainView()
            .environmentObject(manager)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}

struct MainViewAddDrill_Previews: PreviewProvider {
    static var manager = DrillManager(store: try! DrillStore(inMemory: true))

    static var view: some View {
        MainView()
            .environmentObject(manager)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
