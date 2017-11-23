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
    @NSManaged var reminderDate: Date?
    @NSManaged var reminderType: String?
    @NSManaged var remainingDays: NSNumber?
    
    var section: String? {
        
        let days = remainingDays!.int32Value
        switch days {
        case 0...7:
            return "This week"
        case 8...30:
            return "This month"
        case 31...90:
            return "Coming up"
        default:
            return "In a bit..."

        }
        
    }

}
