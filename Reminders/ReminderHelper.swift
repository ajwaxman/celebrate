//
//  ReminderHelper.swift
//  Reminders
//
//  Created by Adam Waxman on 2/17/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit
import Foundation

public class ReminderHelper {
    
    class func getNextOccurenceOfReminderDate(reminderDate: NSDate) -> NSDate {
        let cal = NSCalendar.currentCalendar()
        let today = cal.startOfDayForDate(NSDate())
        let dayAndMonth = cal.components([.Day, .Month],
            fromDate: reminderDate)
        dayAndMonth.hour = 9
        let nextOccurenceOfReminderDate = cal.nextDateAfterDate(today,
            matchingComponents: dayAndMonth,
            options: .MatchNextTimePreservingSmallerUnits)!
        return nextOccurenceOfReminderDate
    }
    
    class func getDaysUntilReminder(nextOccurence: NSDate) -> Int {
        let cal = NSCalendar.currentCalendar()
        let today = cal.startOfDayForDate(NSDate())
        let diff = cal.components([.Day],
            fromDate: today,
            toDate: nextOccurence,
            options: [])
        return diff.day
    }
    
    class func scheduleLocalNotification(reminder: Reminder) {
        let localNotification = UILocalNotification()
        // localNotification.fireDate = getCurrentTime()
        localNotification.fireDate = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!)
        localNotification.alertBody = "It's \(reminder.name!)'s \(reminder.reminderType!) today. Send a note!"
        localNotification.alertAction = "View reminder"
        localNotification.category = "reminderCategory"
        localNotification.userInfo = ["phoneNumber": reminder.phoneNumber!, "reminderObjectId": reminder.objectID.URIRepresentation().absoluteString]
        localNotification.repeatInterval = NSCalendarUnit.Year
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    class func scheduleWeekBeforeLocalNotification(reminder: Reminder) {
        let localNotification = UILocalNotification()
        // localNotification.fireDate = getCurrentTime()
        localNotification.fireDate = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!).dateByAddingTimeInterval(-7*24*60*60)
        localNotification.alertBody = "\(reminder.name!)'s \(reminder.reminderType!) is 1 week away. Present time?"
        localNotification.alertAction = "View reminder"
        localNotification.category = "reminderCategory"
        localNotification.userInfo = ["phoneNumber": reminder.phoneNumber!, "reminderObjectId": reminder.objectID.URIRepresentation().absoluteString]
        localNotification.repeatInterval = NSCalendarUnit.Year
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    
}


