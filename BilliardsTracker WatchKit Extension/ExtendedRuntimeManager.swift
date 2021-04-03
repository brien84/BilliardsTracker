//
//  ExtendedRuntimeManager.swift
//  BilliardsTracker WatchKit Extension
//
//  Created by Marius on 2021-04-03.
//

import Foundation

import WatchKit

final class ExtendedRuntimeManager: NSObject {
    private var session: WKExtendedRuntimeSession?

     func start() {
         session = WKExtendedRuntimeSession()
         session?.delegate = self
         session?.start()
     }

     func stop() {
         if session?.state == .running {
             session?.invalidate()
         }
     }
}

extension ExtendedRuntimeManager: WKExtendedRuntimeSessionDelegate {
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession,
                                didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason,
                                error: Error?) {
        print("extendedRuntimeSession didInvalidateWith: \(reason.rawValue)")
    }

    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSessionDidStart")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extendedRuntimeSessionWillExpire")
    }
}
