//
//  CreateReminderViewController.swift
//  Reminders
//
//  Created by Adam Waxman on 2/6/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit
import CoreData
import ContactsUI

protocol AddContactViewControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}

class CreateReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, CNContactPickerDelegate {
    
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
    var currentTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        txtReminderType.inputView = pickerView
        txtReminderType.text = "Birthday"

        self.title = "Add Reminder"
        
        txtPhoneNumber.delegate = self
        
        txtName.delegate = self
        txtReminderType.delegate = self
        txtReminderType.delegate = self
        addToolBar(txtName)
        addToolBar(txtReminderDate)
        addToolBar(txtReminderType)
        addToolBar(txtPhoneNumber)
        
        txtName.becomeFirstResponder()
        
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
        localNotification.alertBody = "It's \(reminder.name!)'s \(reminder.reminderType!) today. Send a note!"
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
    
    // MARK: - Custom form logic and formatting
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        currentTextField = textField
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == txtName) {
            txtReminderDate.becomeFirstResponder()
        } else if textField == txtReminderDate {
            txtReminderType.becomeFirstResponder()
        } else if textField == txtReminderType {
            txtPhoneNumber.becomeFirstResponder()
        }
        
        return true;
    }
    
    func addToolBar(textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.backgroundColor = UIColor.whiteColor()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red:0.51, green:0.23, blue:0.89, alpha:1.0)
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "nextPressed")
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPressed")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let addFromContactsButton = UIBarButtonItem(title: "Add From Contacts", style: .Plain, target: self, action: "addFromContacts")
        if textField == txtPhoneNumber {
            toolBar.setItems([cancelButton, spaceButton, addFromContactsButton], animated: false)
        } else if textField == txtReminderType {
            toolBar.setItems([cancelButton, spaceButton], animated: false)
        } else {
            toolBar.setItems([cancelButton, spaceButton, nextButton], animated: false)
        }
        toolBar.userInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    func donePressed(){
        view.endEditing(true)
    }
    func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
    func nextPressed() -> Bool {
        
        if currentTextField == txtName {
            txtReminderDate.becomeFirstResponder()
        } else if currentTextField == txtReminderDate {
            txtPhoneNumber.becomeFirstResponder()
        }
        
        return true;
    }
    
    func addFromContacts() {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "phoneNumbers != nil")
        
        contactPickerViewController.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        
        contactPickerViewController.predicateForSelectionOfProperty = NSPredicate(value:true)
        
        contactPickerViewController.delegate = self
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContactProperty contactProperty: CNContactProperty) {
        let phoneNumber = contactProperty.value as! CNPhoneNumber
        
        txtPhoneNumber.text = phoneNumber.stringValue
        
        let currentText = txtPhoneNumber.text ?? ""
        let range: NSRange = (currentText as NSString).rangeOfString(currentText)
        
        formatPhoneNumber(txtPhoneNumber, shouldChangeCharactersInRange: range, replacementString: phoneNumber.stringValue)

    }
    
    func formatPhoneNumber(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
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
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        return formatPhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
    
    // MARK: - Custom Function 
    
    func createReminder() {
        let reminder = NSEntityDescription.insertNewObjectForEntityForName("Reminder", inManagedObjectContext: self.context) as! Reminder
        
        reminder.name = txtName.text
        reminder.reminderType = txtReminderType.text
        reminder.phoneNumber = txtPhoneNumber.text
        
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
            
            navigationController?.popViewControllerAnimated(true)
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
