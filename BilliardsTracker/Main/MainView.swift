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

    @Environment(\.colorScheme) var colorScheme

    @State private var isShowingSettings = false

    var body: some View {
        let navigationBinding = Binding<Bool>(
            get: { session.runState == .running },
            set: { session.runState = $0 ? .running : .stopped }
        )

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
                    .disabled(session.runState == .loading)
                    .alert(item: $session.connectivityError) { error in
                        switch error {
                        case .notReady:
                            return notReadyAlert
                        case .notReachable:
                            return notReachableAlert
                        }
                    }

                    CreateDrillBackgroundButton(store: store)
                        .opacity(drillStore.drills.count == 0 ? 1 : 0)

                    SettingsView(isShowingSettings: $isShowingSettings)
                        .offset(isShowingSettings ? .zero : .settingsViewHiddenOffset)

                    loadingView
                        .opacity(session.runState == .loading ? 1 : 0)

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
            .fullScreenCover(
                isPresented: navigationBinding
            ) {
                IfLetStore(
                    store.scope(
                        state: \.session,
                        action: Main.Action.session
                    ),
                    then: SessionView.init(store:)
                )
            }
            .onChange(of: viewStore.selectedDrill) { newValue in
                if let drill = newValue {
                    session.start(drill: drill)
                } else {
                    session.runState = .stopped
                }
            }
            .onChange(of: viewStore.resultNeedsToBeCreated) { newValue in
                guard let result = newValue else { return }
                guard let drill = viewStore.selectedDrill else { return }
                drillStore.addResult(result, to: drill)
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
            .onChange(of: viewStore.needsToDeleteDrill) { newValue in
                guard newValue else { return }
                guard let drill = viewStore.statistics?.drill else { return }

                withAnimation {
                    drillStore.delete(drill: drill)
                }
            }
            .onChange(of: drillStore.drills) { newValue in
                viewStore.send(.updateDrillList(newValue), animation: .default)
            }
            .onAppear {
                viewStore.send(.updateDrillList(drillStore.drills), animation: .default)
                viewStore.send(.onAppear)
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

    private var notReadyAlert: Alert {
        Alert(title: Text("Watch app is not in Tracked mode!"),
              message: Text("Make sure Tracked mode is selected in Watch app."),
              dismissButton: .default(Text("OK")))
    }

    private var notReachableAlert: Alert {
        Alert(title: Text("Watch app is not reachable!"),
              message: Text("Make sure BilliardsTracker Watch app is installed and running."),
              dismissButton: .default(Text("OK")))
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

// swiftlint:disable force_try
struct MainView_Previews: PreviewProvider {
    static var drillStore = try! DrillStore(inMemory: true, isPreview: true)
    static var session = SessionManager()
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
    static var session = SessionManager()
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
