//
//  DeleteNotificationUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation
import UserNotifications

struct DeleteNotificationUseCase {
    func execute(identifier: String, completion: (() -> Void)? = nil) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
        completion?()
    }
}
