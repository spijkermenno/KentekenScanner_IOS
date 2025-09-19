//
//  GetNotificationsUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation
import UserNotifications

struct NotificationItem: Identifiable {
    let id = UUID()
    let licensePlate: String
    let date: String
}

struct GetNotificationsUseCase {
    func execute(completion: @escaping ([NotificationItem]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let dfInput = DateFormatter()
            dfInput.dateFormat = "yyyyMMdd"
            dfInput.locale = Locale(identifier: "nl_NL")

            let dfOutput = DateFormatter()
            dfOutput.dateStyle = .medium
            dfOutput.timeStyle = .none
            dfOutput.locale = Locale(identifier: "nl_NL")

            let items: [NotificationItem] = requests.compactMap { request in
                guard let kenteken = request.content.userInfo["kenteken"] as? String else {
                    return nil
                }
                let dateStr = request.content.userInfo["notificatiedatum"] as? String
                let formattedDate: String
                if let raw = dateStr, let d = dfInput.date(from: raw) {
                    formattedDate = dfOutput.string(from: d)
                } else {
                    formattedDate = "—"
                }
                return NotificationItem(licensePlate: kenteken, date: formattedDate)
            }
            completion(items)
        }
    }
}
