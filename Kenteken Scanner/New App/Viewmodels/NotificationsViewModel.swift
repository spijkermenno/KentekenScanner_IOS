//
//  NotificationsViewModel.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []

    private let getNotifications: GetNotificationsUseCase
    private let createNotification: CreateNotificationUseCase
    private let deleteNotification: DeleteNotificationUseCase

    init(
        getNotifications: GetNotificationsUseCase = .init(),
        createNotification: CreateNotificationUseCase = .init(),
        deleteNotification: DeleteNotificationUseCase = .init()
    ) {
        self.getNotifications = getNotifications
        self.createNotification = createNotification
        self.deleteNotification = deleteNotification
    }

    func load() {
        getNotifications.execute { [weak self] items in
            Task { @MainActor in
                self?.notifications = items
            }
        }
    }

    func addNotification(for licensePlate: String, fireDate: Date) {
        createNotification.execute(licensePlate: licensePlate, fireDate: fireDate) { [weak self] success in
            if success {
                self?.load()
            }
        }
    }

    func removeNotification(id: String) {
        deleteNotification.execute(identifier: id) { [weak self] in
            self?.load()
        }
    }
}
