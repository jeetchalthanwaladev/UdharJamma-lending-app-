import Foundation
import UserNotifications
import UIKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    // MARK: - PERMISSION
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, error in
            DispatchQueue.main.async {
                print("🔔 Notification permission granted:", granted)
                if let error = error {
                    print("❌ Permission error:", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - TEST NOTIFICATION (25 SECONDS)
    func testPaymentReminder(name: String, amount: Double) {

        let content = UNMutableNotificationContent()
        content.title = "Payment Reminder"
        content.body = "₹\(String(format: "%.2f", amount)) payment recorded for \(name)"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 25,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "TEST-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Test notification error:", error.localizedDescription)
            } else {
                print("✅ Test notification scheduled (25 sec)")
            }
        }
    }

    // MARK: - DAILY REMINDER
    func scheduleDailyReminder(
        txId: UUID,
        name: String,
        amount: Double,
        hour: Int = 9
    ) {

        let content = UNMutableNotificationContent()
        content.title = "Daily Payment Reminder"
        content.body = "₹\(String(format: "%.2f", amount)) pending from \(name)"
        content.sound = .default

        var comp = DateComponents()
        comp.hour = hour

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comp,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "DAILY-\(txId.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - MONTHLY PAYMENT REMINDER
    func scheduleMonthlyReminder(
        txId: UUID,
        name: String,
        amount: Double,
        day: Int = 1,
        hour: Int = 9
    ) {

        let content = UNMutableNotificationContent()
        content.title = "Monthly Payment Reminder"
        content.body = "₹\(String(format: "%.2f", amount)) due from \(name)"
        content.sound = .default

        var comp = DateComponents()
        comp.day = day
        comp.hour = hour

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comp,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "MONTHLY-\(txId.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - MONTHLY INTEREST POST NOTIFICATION
    func scheduleMonthlyInterestPost(
        txId: UUID,
        name: String,
        interestAmount: Double
    ) {

        let content = UNMutableNotificationContent()
        content.title = "Interest Added"
        content.body = "₹\(String(format: "%.2f", interestAmount)) interest added for \(name)"
        content.sound = .default

        var comp = DateComponents()
        comp.day = 1
        comp.hour = 9

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: comp,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "INTEREST-\(txId.uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - CANCEL ALL REMINDERS FOR TRANSACTION
    func cancelAllReminders(for txId: UUID) {
        let identifiers = [
            "DAILY-\(txId.uuidString)",
            "MONTHLY-\(txId.uuidString)",
            "INTEREST-\(txId.uuidString)"
        ]

        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - CANCEL EVERYTHING (SAFE HELPER)
    func cancelAll() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }

    // MARK: - FOREGROUND DISPLAY (IMPORTANT)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
