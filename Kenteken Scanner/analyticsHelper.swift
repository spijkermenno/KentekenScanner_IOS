//
//  analyticsHelper.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper {
    func logEvent(eventkey: String, key: String, value: String) {
        Analytics.logEvent(eventkey, parameters: [
            key: value
          ])
    }
}
