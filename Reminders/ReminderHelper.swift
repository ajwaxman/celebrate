//
//  ReminderHelper.swift
//  Reminders
//
//  Created by Adam Waxman on 2/17/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit
import Foundation

open class ReminderHelper {
    
    class func getNextOccurenceOfReminderDate(_ reminderDate: Date) -> Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var dayAndMonth = (cal as NSCalendar).components([.day, .month],
            from: reminderDate)
        dayAndMonth.hour = 9
        let nextOccurenceOfReminderDate = (cal as NSCalendar).nextDate(after: today,
            matching: dayAndMonth,
            options: .matchNextTimePreservingSmallerUnits)!
        return nextOccurenceOfReminderDate
    }
    
    class func getDaysUntilReminder(_ nextOccurence: Date) -> Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let diff = (cal as NSCalendar).components([.day],
            from: today,
            to: nextOccurence,
            options: [])
        return diff.day!
    }
    
    class func scheduleLocalNotification(_ reminder: Reminder) {
        let localNotification = UILocalNotification()
        // localNotification.fireDate = getCurrentTime()
        localNotification.fireDate = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate! as Date)
        localNotification.alertBody = "It's \(reminder.name!)'s \(reminder.reminderType!) today. Send a note!"
        localNotification.alertAction = "View reminder"
        localNotification.category = "reminderCategory"
        localNotification.userInfo = ["phoneNumber": reminder.phoneNumber!, "reminderObjectId": reminder.objectID.uriRepresentation().absoluteString]
        localNotification.repeatInterval = NSCalendar.Unit.year
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    class func scheduleWeekBeforeLocalNotification(_ reminder: Reminder) {
        let localNotification = UILocalNotification()
        // localNotification.fireDate = getCurrentTime()
        localNotification.fireDate = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate! as Date).addingTimeInterval(-7*24*60*60)
        localNotification.alertBody = "\(reminder.name!)'s \(reminder.reminderType!) is 1 week away. Present time?"
        localNotification.alertAction = "View reminder"
        localNotification.category = "reminderCategory"
        localNotification.userInfo = ["phoneNumber": reminder.phoneNumber!, "reminderObjectId": reminder.objectID.uriRepresentation().absoluteString]
        localNotification.repeatInterval = NSCalendar.Unit.year
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    class func getNotifications() -> [UILocalNotification] {
        return UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification] // loop through notifications...
    }
    
    class func cancelAllNotifications() {
        for notification in (UIApplication.shared.scheduledLocalNotifications! as [UILocalNotification]) { // loop through notifications...
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }
    
    
}


