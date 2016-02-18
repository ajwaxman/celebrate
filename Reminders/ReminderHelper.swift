//
//  ReminderHelper.swift
//  Reminders
//
//  Created by Adam Waxman on 2/17/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

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
        print(diff.day)
        return diff.day
    }
    
}


