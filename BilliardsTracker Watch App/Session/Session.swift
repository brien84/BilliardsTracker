//
//  Session.swift
//  BilliardsTracker Watch App
//
//  Created by Marius on 2023-02-15.
//

import ComposableArchitecture
import Foundation
import WatchKit

struct Session: ReducerProtocol {
    enum Tab: Int {
        case control
        case progress
    }

    struct State: Equatable {
        var alert: AlertState<Action>?
        var currentTab: Session.Tab = .progress
        var result: Result.State?

        let title: String
        let shotCount: Int
        let isContinuous: Bool
        var potCount = 0
        var missCount = 0
        var didPotLastShot: Bool?
        var isPaused = false

        var isCompleted: Bool {
            if isContinuous {
                return remainingShots <= 0
            } else {
                return remainingShots <= 0 || missCount > 0
            }
        }

        var remainingShots: Int {
            let shots = shotCount - potCount - missCount
            guard shots > 0 else { return 0 }
            return shots
        }
    }

    enum Action: Equatable {
        case alertDidDismiss
        case didChangeCurrentTab(Session.Tab)
        case result(Result.Action)

        case didRegisterShot(isSuccess: Bool)
        case pauseButtonDidTap
        case resumeButtonDidTap
        case stopButtonDidTap
        case undoButtonDidTap

        case beginGestureTracking
        case gestureTrackingDidFail
        case didReceiveRuntimeClientExpirationStatus(Bool)
    }

    @Dependency(\.connectivityClient) var connectivityClient
    @Dependency(\.motionClient) var motionClient
    @Dependency(\.runtimeClient) var runtimeClient

    private enum MotionID { }
    private enum RuntimeID { }

    private func sendResultContext(state: inout State) -> EffectTask<Action> {
        let context = ResultContext(potCount: state.potCount, missCount: state.missCount, date: .now)
        return .fireAndForget {
            await connectivityClient.sendResultContext(context)
        }
    }

    private func startMotionClient(state: inout State) -> EffectTask<Action> {
        .run { send in
            do {
                for try await gesture in await motionClient.start() {
                    if gesture == .axisX {
                        await send(.didRegisterShot(isSuccess: true))
                    } else {
                        await send(.didRegisterShot(isSuccess: false))
                    }
                }
            } catch {
                await send(.gestureTrackingDidFail)
            }
        }
        .cancellable(id: MotionID.self, cancelInFlight: true)
    }

    private func startRuntimeClient(state: inout State) -> EffectTask<Action> {
        .run { send in
            let invalidationReason = await runtimeClient.start()
            switch invalidationReason {
            case .none, .expired:
                return
            case .error, .resignedFrontmost, .sessionInProgress, .suppressedBySystem:
                await send(.gestureTrackingDidFail)
            @unknown default:
                return
            }
        }
        .cancellable(id: RuntimeID.self, cancelInFlight: true)
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .alertDidDismiss:
                state.alert = nil
                return .none

            case .didChangeCurrentTab(let tab):
                state.currentTab = tab
                return .none

            case .result(.doneButtonDidTap):
                state.result = nil
                return sendResultContext(state: &state)

            case .result(.restartButtonDidTap):
                let sendResultContext = sendResultContext(state: &state)
                state.potCount = 0
                state.missCount = 0
                state.didPotLastShot = nil
                state.result = nil
                return .merge(
                    startMotionClient(state: &state),
                    startRuntimeClient(state: &state),
                    sendResultContext
                )

            case .didRegisterShot(let isSuccess):
                guard state.remainingShots > 0 else { return .none }

                if isSuccess {
                    state.potCount += 1
                    WKInterfaceDevice().play(.notification)
                } else {
                    state.missCount += 1
                    WKInterfaceDevice().play(.failure)
                }

                state.didPotLastShot = isSuccess

                if state.isCompleted {
                    state.result = Result.State(potCount: state.potCount, missCount: state.missCount)
                    WKInterfaceDevice().play(.success)
                    return .cancel(ids: [MotionID.self, RuntimeID.self])
                }

                return .none

            case .pauseButtonDidTap:
                state.isPaused = true
                state.currentTab = .progress
                WKInterfaceDevice().play(.directionDown)
                return .cancel(ids: [MotionID.self, RuntimeID.self])

            case .resumeButtonDidTap:
                state.isPaused = false
                state.currentTab = .progress
                WKInterfaceDevice().play(.directionUp)
                return .merge(
                    startMotionClient(state: &state),
                    startRuntimeClient(state: &state)
                )

            case .stopButtonDidTap:
                return .cancel(ids: [MotionID.self, RuntimeID.self])

            case .undoButtonDidTap:
                guard let didPotLastShot = state.didPotLastShot else { return .none }

                if didPotLastShot {
                    state.potCount -= 1
                } else {
                    state.missCount -= 1
                }

                state.didPotLastShot = nil
                state.currentTab = .progress
                WKInterfaceDevice().play(.directionDown)
                return .none

            case .beginGestureTracking:
                return .merge(
                    startMotionClient(state: &state),
                    startRuntimeClient(state: &state)
                )

            case .gestureTrackingDidFail:
                guard state.alert == nil else { return .none }
                state.alert = gestureTrackingAlert
                return .cancel(ids: [MotionID.self, RuntimeID.self])

            case .didReceiveRuntimeClientExpirationStatus(let isExpiring):
                guard isExpiring else { return .none }
                return .concatenate(
                    .cancel(id: RuntimeID.self),
                    startRuntimeClient(state: &state)
                )

            }
        }
        .ifLet(\.result, action: /Action.result) {
            Result()
        }
    }
}

// MARK: - Alerts

private extension Session {
    var gestureTrackingAlert: AlertState<Session.Action> {
        AlertState {
            TextState("Attention!")
        } actions: {
            ButtonState(role: .cancel) {
                TextState("OK")
            }
        } message: {
            TextState(
                """
                BilliardsTracker could not initiate gesture tracking.
                Make sure no other workout apps are not actively running.
                """
            )
        }
    }
}
