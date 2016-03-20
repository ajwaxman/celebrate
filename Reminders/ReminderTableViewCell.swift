//
//  ReminderTableViewCell.swift
//  Reminders
//
//  Created by Adam Waxman on 2/2/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    var reminder: Reminder? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var reminderNameTxt: UILabel!
    @IBOutlet weak var reminderDetailsTxt: UILabel!
    @IBOutlet weak var remainingBaseCircle: UIView!
    @IBOutlet weak var reminderRemainingDays: UILabel!
    
    
    func updateUI() {
        
        // reset any existing reminder information
        reminderNameTxt?.text = nil
        reminderDetailsTxt?.text = nil
        
        if let reminder = self.reminder {
            reminderNameTxt.text = reminder.name
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "M/d"
            let reminderDateString = dateFormatter.stringFromDate(reminder.reminderDate!)
            reminderDetailsTxt.text = reminderDateString + " - " + getEventYear(reminder.reminderDate!) + " " + reminder.reminderType!
            
            let remainingDays = reminder.remainingDays as! Int
            if remainingDays < 90 {
                switch reminder.reminderType! {
                    case "Birthday":
                        reminderDetailsTxt.text! += " 🎉"
                    case "Anniversary":
                        reminderDetailsTxt.text! += " ♥️"
                    default: break
                }
            }
            
            reminderRemainingDays.text = reminder.remainingDays?.stringValue
            let currentFont = reminderRemainingDays.font
            let fontName = currentFont.fontName.componentsSeparatedByString("-").first
            let newFont = UIFont(name: "\(fontName!)-Light", size: currentFont.pointSize)
            reminderRemainingDays.font = newFont
        }
        
        createReminderCircle()

    }
    
    func getEventYear(reminderDate: NSDate) -> String {
        let yearOfEvent = NSCalendar.currentCalendar().components(NSCalendarUnit.Year, fromDate: reminderDate, toDate: ReminderHelper.getNextOccurenceOfReminderDate(reminderDate), options:  NSCalendarOptions(rawValue: 0)).year
        return addOrdinal(yearOfEvent)
    }
    
    func addOrdinal(yearOfEvent: Int) -> String {
        if (11...13).contains(yearOfEvent % 100) {
            return "\(yearOfEvent)th"
        }
        switch yearOfEvent % 10 {
        case 1: return "\(yearOfEvent)st"
        case 2: return "\(yearOfEvent)nd"
        case 3: return "\(yearOfEvent)rd"
        default: return "\(yearOfEvent)th"
        }
    }
    
    func createReminderCircle() {
        let circle = remainingBaseCircle
        circle.backgroundColor = UIColor.whiteColor()
        circle.layer.cornerRadius = circle.frame.size.width/2
        
        circle.layer.borderWidth = 2
        
        // Set color based on days remaining
        let remainingDays = reminder?.remainingDays as! Int
        switch remainingDays {
            case 0...7:
                circle.layer.borderColor = UIColor(red:0.137, green:0.812, blue:0.373, alpha:1).CGColor
            case 8...30:
                circle.layer.borderColor = UIColor(red:0.98, green:0.7, blue:0.19, alpha: 0.5).CGColor
            case 31...90:
                circle.layer.borderColor = UIColor(red:0.91, green:0.23, blue:0.19, alpha:0.6).CGColor
            default:
                circle.layer.borderColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:0.6).CGColor
        }
        
        if CFloat(reminder!.remainingDays!) < 30 {
            let currentFont = reminderRemainingDays.font
            let fontName = currentFont.fontName.componentsSeparatedByString("-").first
            let newFont = UIFont(name: "\(fontName!)-Medium", size: currentFont.pointSize)
            reminderRemainingDays.font = newFont
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
