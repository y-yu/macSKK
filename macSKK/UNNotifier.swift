// SPDX-FileCopyrightText: 2024 mtgto <hogerappa@gmail.com>
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import UserNotifications

/// 通知センターへの通知処理
struct UNNotifier {
    // ユーザー辞書の読み込みエラーの通知センター用通知のID
    static let userNotificationReadErrorIdentifier = "net.mtgto.inputmethod.macSKK.userNotification.userDictReadError"
    // ユーザー辞書の書き込みエラーの通知センター用通知のID
    static let userNotificationWriteErrorIdentifier = "net.mtgto.inputmethod.macSKK.userNotification.userDictWriteError"

    static func sendNotificationForUserDict(readError: Error) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("UNUserDictReadErrorTitle", comment: "エラー")
        content.body = NSLocalizedString("UNUserDictReadErrorBody", comment: "ユーザー辞書の読み込みに失敗しました")

        let request = UNNotificationRequest(identifier: Self.userNotificationReadErrorIdentifier, content: content, trigger: nil)
        sendUserNotification(request: request)
    }

    static func sendNotificationForUserDict(failureEntryCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("UNUserDictReadFailureEntryTitle", comment: "エラー")
        content.body = String(format: NSLocalizedString("UNUserDictReadFailureEntryBody", comment: ""), failureEntryCount)

        let request = UNNotificationRequest(identifier: Self.userNotificationReadErrorIdentifier, content: content, trigger: nil)
        sendUserNotification(request: request)
    }

    static func sendNotificationForUserDict(writeError: Error) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("UNUserDictWriteErrorTitle", comment: "エラー")
        content.body = NSLocalizedString("UNUserDictWriteErrorBody", comment: "ユーザー辞書の永続化に失敗しました")

        let request = UNNotificationRequest(identifier: Self.userNotificationWriteErrorIdentifier, content: content, trigger: nil)
        sendUserNotification(request: request)
    }

    private static func sendUserNotification(request: UNNotificationRequest) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization { granted, error in
            if let error {
                logger.log("通知センターへの通知ができない状態です:\(error)")
                return
            }
            if !granted {
                logger.log("通知センターへの通知がユーザーに拒否されています")
                return
            }
            center.add(request) { error in
                if let error {
                    logger.error("通知センターへの通知に失敗しました: \(error)")
                }
            }
        }
    }
}
