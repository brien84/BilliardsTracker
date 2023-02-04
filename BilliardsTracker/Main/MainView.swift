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

    @Environment(\.colorScheme) var colorScheme

    @State private var isShowingSettings = false

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ZStack {
                    PassiveNavigationLink(
                        isActive: viewStore.binding(
                            get: \.isNavigationToStatisticsActive,
                            send: Main.Action.setNavigationToStatistics(isActive:)
                        ),
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

                    DrillsView(store: store.scope(
                        state: \.drillList,
                        action: Main.Action.drillList
                    ))
                    .blur(isShowingSettings)
                    .disabled(isShowingSettings)
                    .disabled(viewStore.isShowingLoadingIndicator)
                    .alert(
                      store.scope(state: \.alert),
                      dismiss: .alertDismissed
                    )

                    CreateDrillBackgroundButton(store: store)
                        .opacity(viewStore.drillList.drills.count == 0 ? 1 : 0)

                    loadingView
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
                        CreateDrillNavigationBarButton(store: store)
                            .disabled(isShowingSettings)
                            .disabled(viewStore.isShowingLoadingIndicator)
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
            .fullScreenCover(
                isPresented: viewStore.binding(
                    get: \.isNavigationToSessionActive,
                    send: Main.Action.setNavigationToSession(isActive:)
                )
            ) {
                IfLetStore(
                    store.scope(
                        state: \.session,
                        action: Main.Action.session
                    ),
                    then: SessionView.init(store:)
                )
            }
            .onAppear {
                viewStore.send(.loadDrills)
                viewStore.send(.onAppear)
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

    private var loadingView: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .opacity(colorScheme == .light ? .loadingViewBackgroundOpacityLight : .loadingViewBackgroundOpacityDark)

            ProgressView()
                .padding()
                .progressViewStyle(CircularProgressViewStyle(tint: .primaryElement))
                .background(Color.secondaryBackground)
                .cornerRadius(.loadingViewCornerRadius)
                .overlay(RoundedRectangle(cornerRadius: .loadingViewCornerRadius)
                            .stroke(Color.secondaryElement, lineWidth: .loadingViewLineWidth))
        }
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

private extension CGFloat {
    static var loadingViewCornerRadius: CGFloat {
        10
    }

    static var loadingViewLineWidth: CGFloat {
        1
    }
}

private extension Double {
    static var loadingViewBackgroundOpacityLight: Double {
        0.25
    }

    static var loadingViewBackgroundOpacityDark: Double {
        0.45
    }
}

// MARK: - Previews

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(store: Store(initialState: Main.State(), reducer: Main()))
    }
}
