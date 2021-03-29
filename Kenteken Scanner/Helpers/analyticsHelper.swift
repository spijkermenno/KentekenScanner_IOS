//
//  analyticsHelper.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import Foundation
import FirebaseAnalytics

class AnalyticsHelper {
    let DEBUG = true
    
    func logEvent(eventkey: String, key: String, value: Any) {
        if !DEBUG {
            let cleanEventKey = eventkey.replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: " ", with: "_")
            print(cleanEventKey)
            Analytics.logEvent(cleanEventKey, parameters: [
                key: value
            ])
        }
    }
    
    func logError(eventkey: String) {
        if !DEBUG {
            let cleanEventKey = eventkey.replacingOccurrences(of: "-", with: "_").replacingOccurrences(of: " ", with: "_")
            Analytics.logEvent(cleanEventKey, parameters: ["error": true])
        }
    }
}
