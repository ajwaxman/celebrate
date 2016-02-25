//
//  DataHelper.swift
//  Reminders
//
//  Created by Adam Waxman on 2/2/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import Foundation
import CoreData

public class DataHelper {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext){
        self.context = context
    }
    
    public func seedDataStore() {
        self.seedReminders()
    }
    
    private func seedReminders() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        
        let reminders = [
            (name: "Adam Waxman",phoneNumber: "216-533-1493",reminderDate: dateFormatter.dateFromString("9/16/88"),reminderType: "birthday"),
            (name: "Melissa Marcus",phoneNumber: "201-555-5555",reminderDate: dateFormatter.dateFromString("12/31/91"),reminderType: "birthday"),
            (name: "Michael Waxman",phoneNumber: "440-725-1377",reminderDate: dateFormatter.dateFromString("10/17/86"),reminderType: "birthday"),
            (name: "Jen Waxman",phoneNumber: "216-272-1234",reminderDate: dateFormatter.dateFromString("8/11/91"),reminderType: "birthday")
        ]
        
        for reminder in reminders {
            let newReminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: context) as! Reminder
            newReminder.name = reminder.name
            newReminder.phoneNumber = reminder.phoneNumber
            newReminder.reminderDate = reminder.reminderDate
            newReminder.reminderType = reminder.reminderType
        }
        
        do {
            try context.save()
        } catch _ {
            
        }
    }
    
    public func printAllReminders() {
        let allReminders = self.getAllReminders() as! [Reminder]
        
        for reminder in allReminders {
            print("Name: \(reminder.name!)\nReminderDate: \(reminder.reminderDate!)\nPhone Number: \(reminder.phoneNumber!)\n\n")
        }
        
    }
    
    public func getAllReminders() -> [AnyObject] {
        let reminderFetchRequest = NSFetchRequest(entityName: "Reminder")
        let primarySortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        
        reminderFetchRequest.sortDescriptors = [primarySortDescriptor]
        
        let allReminders = (try! context.executeFetchRequest(reminderFetchRequest)) as! [Reminder]
        return allReminders
    }
    
    public func deleteAllReminders() {
        let reminderFetchRequest = NSFetchRequest(entityName: "Reminder")
        let allReminders = (try!
            context.executeFetchRequest(reminderFetchRequest)) as! [Reminder]
        
        for reminder in allReminders {
            context.deleteObject(reminder)
            
            do {
                try context.save()
            } catch {
                print("There was a problem deleting this reminder")
            }
            
        }
    }
    
}