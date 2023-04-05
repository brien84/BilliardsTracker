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
                        isActive: viewStore.binding(\.$isNavigationToStatisticsActive),
                        destination: {
                            IfLetStore(
                                store.scope(
                                    state: \.statistics,
                                    action: Main.Action.statistics
                                ),
                                then: StatisticsView.init(store:)
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
            .navigationViewStyle(.stack)
            .sheet(isPresented: viewStore.binding(\.$isNavigationToNewDrillActive)) {
                NewDrillView(store: store.scope(
                    state: \.newDrill,
                    action: Main.Action.newDrill
                ))
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

private struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(Self.backgroundOpacity)

            ProgressView()
                .padding()
                .progressViewStyle(.circular)
                .tint(.primaryElement)
                .background(Color.secondaryBackground)
                .cornerRadius(Self.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: Self.cornerRadius)
                        .stroke(Color.secondaryElement, lineWidth: Self.lineWidth)
                )
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

// MARK: - Constants

private extension LoadingView {
    static let backgroundOpacity: CGFloat = 0.5
    static let cornerRadius: CGFloat = 10
    static let lineWidth: CGFloat = 1
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
    }
}
