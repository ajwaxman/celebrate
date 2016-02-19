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
            reminderDetailsTxt.text = reminder.reminderType
            reminderRemainingDays.text = reminder.remainingDays?.stringValue
        }
        
        createReminderCircle()

    }
    
    func createReminderCircle() {
        let circle = remainingBaseCircle
        circle.backgroundColor = UIColor.whiteColor()
        circle.layer.cornerRadius = circle.frame.size.width/2
        
        let alpha = max(1 - (CFloat((reminder?.remainingDays)!) / 365.0), 0.2)
        circle.layer.borderColor = UIColor(red: 0.565, green: 0.075, blue:0.996, alpha: CGFloat(alpha) ).CGColor
        circle.layer.borderWidth = 2
        
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
