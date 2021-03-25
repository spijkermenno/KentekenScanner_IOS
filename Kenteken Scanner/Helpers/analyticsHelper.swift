//
//  analyticsHelper.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper {
    
    func logEvent(eventkey: String, key: String, value: Any) {
        print("event log")
        let cleanEventKey = eventkey.replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: " ", with: "_")
        print(cleanEventKey)
        Analytics.logEvent(cleanEventKey, parameters: [
            key: value
          ])
    }
    
    func logError(eventkey: String) {
        print("error log")
        let cleanEventKey = eventkey.replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: " ", with: "_")
        Analytics.logEvent(cleanEventKey, parameters: ["error": true])
    }
}
