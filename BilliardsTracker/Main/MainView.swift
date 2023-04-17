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

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    PassiveNavigationLink(
                        isActive: viewStore.binding(\.$isNavigationToDrillLogActive),
                        destination: {
                            IfLetStore(
                                store.scope(
                                    state: \.drillLog,
                                    action: Main.Action.drillLog
                                ),
                                then: DrillLogView.init(store:)
                            )
                        }
                    )

                    Color.primaryBackground
                        .ignoresSafeArea()

                    DrillListView(store: store.scope(
                        state: \.drillList,
                        action: Main.Action.drillList
                    ))
                    .disabled(viewStore.isShowingLoadingIndicator)

                    LoadingView()
                        .opacity(viewStore.isShowingLoadingIndicator ? 1 : 0)
                }
                .navigationBarTitle("Drills")
                .navigationBarItems(
                    leading:
                        SettingsView(store: store.scope(
                            state: \.settings,
                            action: Main.Action.settings
                        ))
                        .disabled(viewStore.isShowingLoadingIndicator),
                    trailing:
                        NewDrillNavigationBarButton(
                            isNavigationActive: viewStore.binding(\.$isNavigationToNewDrillActive)
                        )
                        .disabled(viewStore.isShowingLoadingIndicator)
                )
            }
            .preferredColorScheme(viewStore.settings.appearance.colorScheme)
            .navigationViewStyle(.stack)
            .sheet(isPresented: viewStore.binding(\.$isNavigationToNewDrillActive)) {
                NewDrillView(store: store.scope(
                    state: \.newDrill,
                    action: Main.Action.newDrill
                ))
            }
            .sheet(isPresented: viewStore.binding(\.$isNavigationToOnboardActive)) {
                OnboardView { viewStore.send(.onboardViewDidDismiss) }
            }
            .fullScreenCover(isPresented: viewStore.binding(\.$isNavigationToSessionActive)) {
                IfLetStore(
                    store.scope(
                        state: \.session,
                        action: Main.Action.session
                    ),
                    then: SessionView.init(store:)
                )
            }
            .alert(
                store.scope(state: \.alert),
                dismiss: .alertDidDismiss
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

private struct NewDrillNavigationBarButton: View {
    @Binding var isNavigationActive: Bool

    var body: some View {
        Button(
            action: {
                isNavigationActive = true
            },
            label: {
                Image(systemName: "plus")
                    .imageScale(.large)
            }
        )
    }
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
    }
}
