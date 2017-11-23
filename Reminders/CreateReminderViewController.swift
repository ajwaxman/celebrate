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
    func didFetchContacts(_ contacts: [CNContact])
}

class CreateReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, CNContactPickerDelegate {
    
    // Mark: - Properties
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
        
        let saveBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(CreateReminderViewController.createReminder))
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        setupNotificationSettings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dateReminderEditing(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(CreateReminderViewController.dateReminderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func dateReminderValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        txtReminderDate.text = dateFormatter.string(from: sender.date)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reminderTypeOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reminderTypeOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtReminderType.text = reminderTypeOptions[row]
    }
    
    // MARK: - Notification Logic
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.shared.currentUserNotificationSettings
        
        if (notificationSettings.types == UIUserNotificationType()) {
            
            // Specify the notification actions
            
            let callAction = UIMutableUserNotificationAction()
            callAction.identifier = "call"
            callAction.title = "Call"
            callAction.activationMode = .foreground
            callAction.isDestructive = false
            callAction.isAuthenticationRequired = true
            
            let textAction = UIMutableUserNotificationAction()
            textAction.identifier = "text"
            textAction.title = "Text"
            textAction.activationMode = .foreground
            textAction.isDestructive = false
            textAction.isAuthenticationRequired = true
            
            let actionsArray: [UIUserNotificationAction] = [textAction, callAction]
            let actionsArrayMinimal: [UIUserNotificationAction] = [textAction, callAction]
            
            // Specify the category related to the above actions
            let reminderCategory = UIMutableUserNotificationCategory()
            reminderCategory.identifier = "reminderCategory"
            reminderCategory.setActions(actionsArray, for: .default)
            reminderCategory.setActions(actionsArrayMinimal, for: .minimal)
            
            let categoriesForSettings: Set<UIUserNotificationCategory> = Set([reminderCategory])
            
            let newNotificationSettings = UIUserNotificationSettings(types: [.alert], categories: categoriesForSettings)
            
            UIApplication.shared.registerUserNotificationSettings(newNotificationSettings)
            
        }
    }
    
    func getDateFromString(_ date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        return dateFormatter.date(from: date)!
    }
    
    // Get current time when testing notifications
    func getCurrentTime() -> Date {
        let date = Date()
        let calendar = Calendar.current
        var components = (calendar as NSCalendar).components([.day, .month, .year, .hour, .minute, .second], from: date)
        components.second = 0
        
        let currentTime: Date! = Calendar.current.date(from: components)
        return currentTime
    }
    
    // MARK: - Custom form logic and formatting
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentTextField = textField
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == txtName) {
            txtReminderDate.becomeFirstResponder()
        } else if textField == txtReminderDate {
            txtReminderType.becomeFirstResponder()
        } else if textField == txtReminderType {
            txtPhoneNumber.becomeFirstResponder()
        }
        
        return true;
    }
    
    func addToolBar(_ textField: UITextField){
        let toolBar = UIToolbar()
        toolBar.backgroundColor = UIColor.white
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red:0.51, green:0.23, blue:0.89, alpha:1.0)
        let nextButton = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.done, target: self, action: #selector(CreateReminderViewController.nextPressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateReminderViewController.cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let addFromContactsButton = UIBarButtonItem(title: "Add From Contacts", style: .plain, target: self, action: #selector(CreateReminderViewController.addFromContacts))
        if textField == txtPhoneNumber {
            toolBar.setItems([cancelButton, spaceButton, addFromContactsButton], animated: false)
        } else if textField == txtReminderType {
            toolBar.setItems([cancelButton, spaceButton], animated: false)
        } else {
            toolBar.setItems([cancelButton, spaceButton, nextButton], animated: false)
        }
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    func donePressed(){
        view.endEditing(true)
    }
    @objc func cancelPressed(){
        view.endEditing(true) // or do something
    }
    
    @objc func nextPressed() -> Bool {
        
        if currentTextField == txtName {
            txtReminderDate.becomeFirstResponder()
        } else if currentTextField == txtReminderDate {
            txtPhoneNumber.becomeFirstResponder()
        }
        
        return true;
    }
    
    @objc func addFromContacts() {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.predicateForEnablingContact = NSPredicate(format: "phoneNumbers != nil")
        
        contactPickerViewController.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        
        contactPickerViewController.predicateForSelectionOfProperty = NSPredicate(value:true)
        
        contactPickerViewController.delegate = self
        
        present(contactPickerViewController, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        let phoneNumber = contactProperty.value as! CNPhoneNumber
        
        txtPhoneNumber.text = phoneNumber.stringValue
        
        let currentText = txtPhoneNumber.text ?? ""
        let range: NSRange = (currentText as NSString).range(of: currentText)
        
        formatPhoneNumber(txtPhoneNumber, shouldChangeCharactersInRange: range, replacementString: phoneNumber.stringValue)

    }
    
    func formatPhoneNumber(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == txtPhoneNumber && string.characters.count > 0
        {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let components = newString.components(separatedBy: CharacterSet.decimalDigits.inverted)
            
            let decimalString = components.joined(separator: "") as String
            let decimalNString = components.joined(separator: "") as  NSString
            
            let rangeOfDecimalString = (decimalString.startIndex ..< decimalString.characters.index(decimalString.startIndex, offsetBy: 1))
            let firstCharacterStr = decimalString.substring(with: rangeOfDecimalString)
            
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
                formattedString.append("1 ")
                index += 1
            }
            if (length - index) > 3
            {
                let areaCode = decimalNString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("(%@) ", areaCode)
                index += 3
            }
            if length - index > 3
            {
                let prefix = decimalNString.substring(with: NSMakeRange(index, 3))
                formattedString.appendFormat("%@-", prefix)
                index += 3
            }
            
            let remainder = decimalNString.substring(from: index)
            formattedString.append(remainder)
            textField.text = formattedString as String
            return false
        }
        else
        {
            return true
        }
    }
    
    func digitsOnly(_ string: String) -> String {
        let stringArray = string.components(
            separatedBy: CharacterSet.decimalDigits.inverted)
        let newString = stringArray.joined(separator: "")
        
        return newString
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return formatPhoneNumber(textField, shouldChangeCharactersInRange: range, replacementString: string)
    }
    
    // MARK: - Custom Function 
    
    @objc func createReminder() {
        let reminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: self.context) as! Reminder
        
        reminder.name = txtName.text
        reminder.reminderType = txtReminderType.text
        reminder.phoneNumber = digitsOnly(txtPhoneNumber.text!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yy"
        if let reminderDateString = txtReminderDate.text {
            let reminderDate = getDateFromString(reminderDateString)
            reminder.reminderDate = reminderDate
            reminder.remainingDays = ReminderHelper.getDaysUntilReminder(ReminderHelper.getNextOccurenceOfReminderDate(reminderDate)) as NSNumber?
        }
        
        
        
        do {
            try self.context.save()
            ReminderHelper.scheduleLocalNotification(reminder)
            ReminderHelper.scheduleWeekBeforeLocalNotification(reminder)
            
            navigationController?.popViewController(animated: true)
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
