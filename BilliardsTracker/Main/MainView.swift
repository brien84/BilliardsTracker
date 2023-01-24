//
//  MainView.swift
//  BilliardsTracker
//
//  Created by Marius on 2021-06-14.
//

import ComposableArchitecture
import SwiftUI

struct MainView: View {
    let store: StoreOf<Main>

    @EnvironmentObject var session: SessionManager
    @EnvironmentObject var drillStore: StoreManager

    @State private var isShowingSettings = false

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    Color.primaryBackground
                        .ignoresSafeArea()

                    DrillsView(store: store.scope(
                        state: \.drillList,
                        action: Main.Action.drillList
                    ))
                    .blur(isShowingSettings)
                    .disabled(isShowingSettings)

                    CreateDrillBackgroundButton(store: store)
                        .opacity(drillStore.drills.count == 0 ? 1 : 0)

                    SettingsView(isShowingSettings: $isShowingSettings)
                        .offset(isShowingSettings ? .zero : .settingsViewHiddenOffset)
                }
                .navigationBarTitle("Drills")
                .navigationBarItems(
                    leading:
                        settingsButton
                            .disabled(session.runState == .loading),
                    trailing:
                        CreateDrillNavigationBarButton(store: store)
                            .disabled(isShowingSettings)
                            .disabled(session.runState == .loading)
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isNavigationToCreateDrillActive,
                    send: Main.Action.setNavigationToCreateDrill(isActive:)
                )
            ) {
                IfLetStore(
                    store.scope(
                        state: \.createDrill,
                        action: Main.Action.createDrill
                    ),
                    then: CreateDrillView.init(store:)
                )
            }
            .onChange(of: viewStore.needsToCreateDrill) { newValue in
                guard newValue else { return }
                guard let drill = viewStore.createDrill else { return }

                withAnimation {
                    drillStore.addDrill(
                        title: drill.title.isEmpty ? "Drill Title" : drill.title,
                        attempts: Int(drill.attempts),
                        isFailable: drill.isFailable
                    )
                }
            }
            .onChange(of: drillStore.drills) { newValue in
                viewStore.send(.updateDrillList(newValue), animation: .default)
            }
            .onAppear {
                viewStore.send(.updateDrillList(drillStore.drills), animation: .default)
            }
            .alert(item: $drillStore.savingError) { _ in
                savingAlert
            }
        }
    }

    private var savingAlert: Alert {
        Alert(
            title: Text("Something went wrong!"),
            message: Text("Latest changes will not be saved."),
            dismissButton: .default(Text("OK"))
        )
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
        .accessibility(identifier: "mainView_settingsButton")
    }
}

private struct CreateDrillBackgroundButton: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: {
                    viewStore.send(.setNavigationToCreateDrill(isActive: true))
                },
                label: {
                    VStack {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .imageScale(.large)
                            .scaleEffect(Self.imageScale)

                        Text("Create drill")
                            .font(.title)
                            .padding(Self.textPadding)
                    }
                }
            )
            .foregroundColor(.primaryElement)
            .accessibility(identifier: "mainView_createDrillButtonBackground")
        }
    }
}

private struct CreateDrillNavigationBarButton: View {
    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button(
                action: {
                    viewStore.send(.setNavigationToCreateDrill(isActive: true))
                },
                label: {
                    Image(systemName: "plus")
                        .imageScale(.large)
                }
            )
            .accessibility(identifier: "mainView_createDrillButtonNavigation")
        }
    }
}

private extension CreateDrillBackgroundButton {
    static let imageScale: CGFloat = 2.0
    static let textPadding: CGFloat = 32
}

private extension CGSize {
    static var settingsViewHiddenOffset: CGSize {
        CGSize(width: -500, height: 0)
    }
}

// swiftlint:disable force_try
struct MainView_Previews: PreviewProvider {
    static var drillStore = try! DrillStore(inMemory: true, isPreview: true)
    static var session = SessionManager(store: drillStore)
    static var store = StoreManager(store: drillStore)

    static var view: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
            .environmentObject(session)
            .environmentObject(store)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}

struct MainViewCreateDrillBackground_Previews: PreviewProvider {
    static var drillStore = try! DrillStore(inMemory: true, isPreview: false)
    static var session = SessionManager(store: drillStore)
    static var store = StoreManager(store: drillStore)

    static var view: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
            .environmentObject(session)
            .environmentObject(store)
    }

    static var previews: some View {
        view.preferredColorScheme(.light)
        view.preferredColorScheme(.dark)
    }
}
// swiftlint:enable force_try
