//
//  Reminder+CoreDataProperties.swift
//  Reminders
//
//  Created by Adam Waxman on 2/2/16.
//  Copyright © 2016 Waxman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Reminder {

    @NSManaged var name: String?
    @NSManaged var phoneNumber: String?
    @NSManaged var reminderDate: NSDate?
    @NSManaged var reminderType: String?
    @NSManaged var remainingDays: NSNumber?

}
