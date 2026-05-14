//
//  NotificationManager.swift
//  CU_Meet_project
//

import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }

    // Show notifications even when the app is in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func scheduleReminder(for booking: Booking) {
        let startDate = startDateTime(for: booking)

        guard let fireDate = Calendar.current.date(
            byAdding: .minute,
            value: -15,
            to: startDate
        ),
        fireDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Booking"
        content.body = "\(booking.roomName) starts in 15 minutes (\(booking.timeSlot))"
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: booking.id,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for bookingID: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [bookingID])
    }

    private func startDateTime(for booking: Booking) -> Date {
        let parts = booking.timeSlot.components(separatedBy: " - ")

        guard let startPart = parts.first else {
            return booking.date
        }

        let timeParts = startPart
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: ":")

        guard timeParts.count == 2,
              let hour = Int(timeParts[0]),
              let minute = Int(timeParts[1]) else {
            return booking.date
        }

        return Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: booking.date
        ) ?? booking.date
    }

    #if DEBUG
    func scheduleTestReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Test Notification"
        content.body = "Notification looks something like this"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 5,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "test-notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
    #endif
}
