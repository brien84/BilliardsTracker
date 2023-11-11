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
    struct State: Equatable {
        var alert: AlertState<Action>?
        var result: Result.State?

        let title: String
        let shotCount: Int
        let isContinuous: Bool
        let isRestarting: Bool
        var potCount = 0
        var missCount = 0
        var didPotLastShot: Bool?
        var isPaused = false

        var shouldRestart: Bool {
            !isContinuous && isRestarting && missCount > 0
        }

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
        case result(Result.Action)

        case didRegisterShot(isSuccess: Bool)
        case pauseButtonDidTap
        case resumeButtonDidTap
        case stopButtonDidTap
        case undoButtonDidTap

        case onAppear
        case onDisappear
        case didDismissGestureTrackingError
        case didEncounterGestureTrackingError
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
                await send(.didEncounterGestureTrackingError)
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
                await send(.didEncounterGestureTrackingError)
            @unknown default:
                return
            }
        }
        .cancellable(id: RuntimeID.self, cancelInFlight: true)
    }

    private func restartSession(state: inout State) -> EffectTask<Action> {
        let sendResultContext = sendResultContext(state: &state)
        state.potCount = 0
        state.missCount = 0
        state.didPotLastShot = nil
        state.result = nil
        WKInterfaceDevice().play(.start)
        return .merge(
            startMotionClient(state: &state),
            startRuntimeClient(state: &state),
            sendResultContext
        )
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {

            case .result(.doneButtonDidTap):
                state.result = nil
                WKInterfaceDevice().play(.stop)
                return sendResultContext(state: &state)

            case .result(.restartButtonDidTap):
                return restartSession(state: &state)

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
                    WKInterfaceDevice().play(.success)
                    if state.shouldRestart {
                        return restartSession(state: &state)
                    } else {
                        state.result = Result.State(potCount: state.potCount, missCount: state.missCount)
                        return .cancel(ids: [MotionID.self, RuntimeID.self])
                    }
                }

                return .task {
                    .didReceiveRuntimeClientExpirationStatus(
                        await runtimeClient.getExpirationStatus()
                    )
                }

            case .pauseButtonDidTap:
                state.isPaused = true
                WKInterfaceDevice().play(.directionDown)
                return .cancel(ids: [MotionID.self, RuntimeID.self])

            case .resumeButtonDidTap:
                state.isPaused = false
                WKInterfaceDevice().play(.directionUp)
                return .merge(
                    startMotionClient(state: &state),
                    startRuntimeClient(state: &state)
                )

            case .stopButtonDidTap:
                WKInterfaceDevice().play(.stop)
                return .none

            case .undoButtonDidTap:
                guard let didPotLastShot = state.didPotLastShot else { return .none }

                if didPotLastShot {
                    state.potCount -= 1
                } else {
                    state.missCount -= 1
                }

                state.didPotLastShot = nil
                WKInterfaceDevice().play(.retry)
                return .none

            case .onAppear:
                guard state.alert == nil else { return .none }
                WKInterfaceDevice().play(.start)
                return .merge(
                    startMotionClient(state: &state),
                    startRuntimeClient(state: &state)
                )

            case .onDisappear:
                return .cancel(ids: [MotionID.self, RuntimeID.self])

            case .didDismissGestureTrackingError:
                return .none

            case .didEncounterGestureTrackingError:
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
            ButtonState(role: .cancel, action: .didDismissGestureTrackingError) {
                TextState("OK")
            }
        } message: {
            TextState(
                """
                BilliardsTracker could not initiate gesture tracking.
                Make sure no other workout apps are not actively running.
                If you encounter this error during the session,
                try pausing and then resuming the drill.
                """
            )
        }
    }
}
