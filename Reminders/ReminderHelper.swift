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
    
    class func getCurrentTime() -> Date {
        let date = Date()
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.day, .month, .year, .hour, .minute, .second], from: date)
        components.second = 0
        
        let currentTime: Date! = Calendar.current.date(from: components)
        return currentTime
    }
    
    class func scheduleLocalNotification(_ reminder: Reminder) {
        let localNotificationContent = UNMutableNotificationContent()
        localNotificationContent.body = "It's \(reminder.name!)'s \(reminder.reminderType!) today. Send a note!"
        localNotificationContent.userInfo = ["phoneNumber": reminder.phoneNumber!, "reminderObjectId": reminder.objectID.uriRepresentation().absoluteString]
        
        // localNotification.fireDate = ReminderHelper.getCurrentTime().addingTimeInterval(60)
        let nextTriggerDate = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate! as Date)
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: nextTriggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        
        let request = UNNotificationRequest(identifier: "Reminder", content: localNotificationContent, trigger: trigger) // Schedule the notification.

        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
             if let theError = error {
                 // Handle any errors
                print("There was an error")
             }
        }
        print(localNotificationContent)
    }
    
    class func scheduleWeekBeforeLocalNotification(_ reminder: Reminder) {
        let localNotificationContent = UNMutableNotificationContent()
        localNotificationContent.body = "\(reminder.name!)'s \(reminder.reminderType!) is 1 week away. Present time?"
        localNotificationContent.userInfo = ["phoneNumber": reminder.phoneNumber!, "reminderObjectId": reminder.objectID.uriRepresentation().absoluteString]

        
        // localNotification.fireDate = ReminderHelper.getCurrentTime()
        let nextTriggerDate = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate! as Date).addingTimeInterval(-7*24*60*60)
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: nextTriggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)

        let request = UNNotificationRequest(identifier: "Reminder", content: localNotificationContent, trigger: trigger) // Schedule the notification.

        let center = UNUserNotificationCenter.current()
        center.add(request) { (error : Error?) in
             if let theError = error {
                 // Handle any errors
                print("There was an error")
             }
        }
        print(localNotificationContent)
    }
    
    
//    class func getNotifications() -> [UNNotificationRequest] {
//        let center = UNUserNotificationCenter.current()
//        return center.getPendingNotificationRequests(completionHandler: { requests in
//            for request in requests {
//                print(request)
//            }
//        })
//    }
    
    class func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
    
    
}


