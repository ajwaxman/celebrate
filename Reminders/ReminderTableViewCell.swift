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
            reminderRemainingDays.text = "234"
        }
        
        createReminderCircle()

    }
    
    func createReminderCircle() {
        let circle = remainingBaseCircle
        circle.backgroundColor = UIColor.whiteColor()
        circle.layer.cornerRadius = circle.frame.size.width/2
        
        circle.layer.borderColor = UIColor(red: 0.565, green: 0.075, blue:0.996, alpha: 1.0 ).CGColor
        circle.layer.borderWidth = 2
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
