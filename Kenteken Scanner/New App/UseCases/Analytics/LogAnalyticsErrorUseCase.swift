//
//  LogAnalyticsErrorUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation
import FirebaseAnalytics

struct LogAnalyticsErrorUseCase {
    let debug: Bool

    init(debug: Bool = false) {
        self.debug = debug
    }

    func callAsFunction(_ eventKey: String) {
        guard !debug else {
            print("[DEBUG] Analytics error: \(eventKey)")
            return
        }

        let cleanEventKey = eventKey
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        Analytics.logEvent(cleanEventKey, parameters: ["error": true])
    }
}
