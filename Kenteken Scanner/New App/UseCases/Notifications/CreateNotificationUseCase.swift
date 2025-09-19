//
//  CreateNotificationUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation
import UserNotifications

struct CreateNotificationUseCase {
    func execute(
        licensePlate: String,
        fireDate: Date,
        completion: @escaping (Bool) -> Void
    ) {
        let content = UNMutableNotificationContent()
        content.title = "APK Alert"
        content.body = "De APK van kenteken \(licensePlate) verloopt bijna!"
        content.sound = .default
        content.userInfo = [
            "kenteken": licensePlate,
            "notificatiedatum": DateFormatter.yyyyMMdd.string(from: fireDate)
        ]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: fireDate.timeIntervalSinceNow,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }
}

fileprivate extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.locale = Locale(identifier: "nl_NL")
        return df
    }()
}
