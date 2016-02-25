//
//  CreateReminderViewController.swift
//  Reminders
//
//  Created by Adam Waxman on 2/6/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit
import CoreData

class CreateReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    // Mark: - Properties
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtReminderDate: UITextField!
    
    @IBOutlet weak var txtReminderType: UITextField!
    
    @IBOutlet weak var txtPhoneNumber: UITextField!
    
    var reminderTypeOptions = ["Birthday", "Anniversary"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        txtReminderType.inputView = pickerView
        txtReminderType.text = "Birthday"

        self.title = "Add Reminder"
        
        txtPhoneNumber.delegate = self
        
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "createReminder")
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        setupNotificationSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dateReminderEditing(sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("dateReminderValueChanged:"), forControlEvents: .ValueChanged)
    }
    
    func dateReminderValueChanged(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        txtReminderDate.text = dateFormatter.stringFromDate(sender.date)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reminderTypeOptions.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reminderTypeOptions[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtReminderType.text = reminderTypeOptions[row]
    }
    
    // MARK: - Notification Logic
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if (notificationSettings.types == .None) {
            
            // Specify the notification actions
            
            let callAction = UIMutableUserNotificationAction()
            callAction.identifier = "call"
            callAction.title = "Call"
            callAction.activationMode = .Foreground
            callAction.destructive = false
            callAction.authenticationRequired = false
            
            let textAction = UIMutableUserNotificationAction()
            textAction.identifier = "text"
            textAction.title = "Text"
            textAction.activationMode = .Foreground
            textAction.destructive = false
            textAction.authenticationRequired = false
            
            let actionsArray: [UIUserNotificationAction] = [textAction, callAction]
            let actionsArrayMinimal: [UIUserNotificationAction] = [textAction, callAction]
            
            // Specify the category related to the above actions
            let reminderCategory = UIMutableUserNotificationCategory()
            reminderCategory.identifier = "reminderCategory"
            reminderCategory.setActions(actionsArray, forContext: .Default)
            reminderCategory.setActions(actionsArrayMinimal, forContext: .Minimal)
            
            let categoriesForSettings: Set<UIUserNotificationCategory> = Set([reminderCategory])
            
            let newNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert], categories: categoriesForSettings)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
            
        }
    }
    
    func scheduleLocalNotification(reminder: Reminder) {
        let localNotification = UILocalNotification()
        // localNotification.fireDate = getCurrentTime()
        localNotification.fireDate = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!)
        localNotification.alertBody = "It's \(reminder.name)'s \(reminder.reminderType) today. Send a note!"
        localNotification.alertAction = "View reminder"
        localNotification.category = "reminderCategory"
        localNotification.userInfo = ["phoneNumber": reminder.phoneNumber!, "reminderObjectId": reminder.objectID.URIRepresentation().absoluteString]
        localNotification.repeatInterval = NSCalendarUnit.Year
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    func getDateFromString(date: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        return dateFormatter.dateFromString(date)!
    }
    
    // Get current time when testing notifications
    func getCurrentTime() -> NSDate {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Month, .Year, .Hour, .Minute, .Second], fromDate: date)
        components.second = 0
        components.minute += 1
        
        let currentTime: NSDate! = NSCalendar.currentCalendar().dateFromComponents(components)
        return currentTime
    }
    
    // MARK: - Form formattingS
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        if textField == txtPhoneNumber
        {
            let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
            let components = newString.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet)
            
            let decimalString = components.joinWithSeparator("") as String
            let decimalNString = components.joinWithSeparator("") as  NSString

            let rangeOfDecimalString = Range(start: decimalString.startIndex,
                end: decimalString.startIndex.advancedBy(1))
            let firstCharacterStr = decimalString.substringWithRange(rangeOfDecimalString)
            
            let length = decimalNString.length
            let hasLeadingOne = length > 0 && firstCharacterStr == "1"
            
            if length == 0 || (length > 10 && !hasLeadingOne) || length > 11
            {
                let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
                
                return (newLength > 10) ? false : true
            }
            var index = 0 as Int
            let formattedString = NSMutableString()
            
            if hasLeadingOne
            {
                print("leading one")
                formattedString.appendString("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalNString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalNString.substringWithRange(NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalNString.substringFromIndex(index)
            formattedString.appendString(remainder)
            textField.text = formattedString as String
            return false
        }
        else
        {
            return true
        }
    }
    
    // MARK: - Custom Function 
    
    func createReminder() {
        let reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.context) as! Reminder
        
        reminder.name = txtName.text
        reminder.reminderType = txtReminderType.text
        reminder.phoneNumber = "2165331493"
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        if let reminderDateString = txtReminderDate.text {
            let reminderDate = getDateFromString(reminderDateString)
            reminder.reminderDate = reminderDate
            reminder.remainingDays = ReminderHelper.getDaysUntilReminder(ReminderHelper.getNextOccurenceOfReminderDate(reminderDate))
        }
        
        
        
        do {
            try self.context.save()
            scheduleLocalNotification(reminder)
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                // ReminderTableViewController.tableVie
            })
            
            navigationController?.popViewControllerAnimated(true)
            CATransaction.commit()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
