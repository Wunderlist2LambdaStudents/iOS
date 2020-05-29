//
//  NotificationHelper.swift
//  WunderList
//
//  Created by Kenny on 5/29/20.
//  Copyright © 2020 Hazy Studios. All rights reserved.
//

import UserNotifications
import UIKit

enum NotificationType {
    case nonRecurring
    case daily
    case weekly
    case monthly
}

class NotificationController: NSObject, UNUserNotificationCenterDelegate {

    // MARK: - Class Properties -
    let notificationCenter = UNUserNotificationCenter.current()
    private let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    private var date = Date()
    static var shared = NotificationController()

    private override init() { }

    // MARK: - Request permission -
    func notificationRequest() {
        notificationCenter.requestAuthorization(options: options) { (didAllow, _) in
           if !didAllow {
               print("User has declined notifications")
           }
       }
    }

    func triggerNotification(
        todo: Todo,
        notificationType: NotificationType,
        onDate date: Date,
        withId identifier: String
    ) {
        var recurring = false
        switch notificationType {
        case .nonRecurring:
            break
        case .daily:
            recurring = true
        case .weekly:
            recurring = true
        case .monthly:
            recurring = true
        }
        self.date = date
        let notificationDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: date
        )
        let identifier = identifier
        let content = scheduleNotification(todo: todo, notificationType: notificationType)
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: recurring)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        notificationCenter.add(request) { (error) in
            print("notification: \(request.identifier)")
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
    }

    func disableNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    // MARK: Helper Methods
    private func scheduleNotification(todo: Todo, notificationType: NotificationType) -> UNMutableNotificationContent {
        print("Scheduling")
        let content = UNMutableNotificationContent()
        content.sound = .default
        if let title = todo.title {
            content.title = "Reminder:\n \(title)"
        }
        return content
    }
}
