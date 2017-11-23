//
//  DataHelper.swift
//  Reminders
//
//  Created by Adam Waxman on 2/2/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import Foundation
import CoreData

open class DataHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
    }
    
    open func seedDataStore() {
        self.seedReminders()
    }
    
    fileprivate func seedReminders() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        
        let reminders = [

            
            // Testing

            (name: "TBD",phoneNumber: "555-555-5555",reminderDate: dateFormatter.date(from: "1/1/11"),reminderType: "birthday")

        ]
        
        for reminder in reminders {
            let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: context) as! Reminder
            newReminder.name = reminder.name
            newReminder.phoneNumber = reminder.phoneNumber
            newReminder.reminderDate = reminder.reminderDate
            newReminder.reminderType = reminder.reminderType
            newReminder.remainingDays = ReminderHelper.getDaysUntilReminder(ReminderHelper.getNextOccurenceOfReminderDate(newReminder.reminderDate!)) as NSNumber?
            ReminderHelper.scheduleLocalNotification(newReminder)
            ReminderHelper.scheduleWeekBeforeLocalNotification(newReminder)
        }
        
        do {
            try context.save()
        } catch _ {
            
        }
    }
    
    open func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        
        if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
            print("App already launched")
            print(isAppAlreadyLaunchedOnce)
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print(isAppAlreadyLaunchedOnce)
            print("App launched first time")
            return false
        }
        
    }
    
    open func printAllReminders() {
        let allReminders = self.getAllReminders() as! [Reminder]
        
        for reminder in allReminders {
            print("Name: \(reminder.name!)\nReminderDate: \(reminder.reminderDate!)\nPhone Number: \(reminder.phoneNumber!)\n\n")
        }
        
    }
    
    open func getAllReminders() -> [AnyObject] {
        let reminderFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        reminderFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allReminders = (try! context.fetch(reminderFetchRequest)) as! [Reminder]
        return allReminders
    }
    
    open func deleteAllReminders() {
        let reminderFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        let allReminders = (try!
            context.fetch(reminderFetchRequest)) as! [Reminder]
        
        for reminder in allReminders {
            context.delete(reminder)
            
            do {
                try context.save()
            } catch {
                print("There was a problem deleting this reminder")
            }
            
        }
    }
    
}
