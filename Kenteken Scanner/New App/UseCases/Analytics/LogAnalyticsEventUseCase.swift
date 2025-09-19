//
//  LogAnalyticsEventUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation
import FirebaseAnalytics

struct LogAnalyticsEventUseCase {
    let debug: Bool

    init(debug: Bool = false) {
        self.debug = debug
    }

    func callAsFunction(_ eventKey: String, parameters: [String: Any]? = nil) {
        guard !debug else {
            print("[DEBUG] Analytics event: \(eventKey), params: \(parameters ?? [:])")
            return
        }

        let cleanEventKey = eventKey
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        Analytics.logEvent(cleanEventKey, parameters: parameters)
    }
}
