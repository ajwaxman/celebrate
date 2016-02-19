//
//  CreateReminderViewController.swift
//  Reminders
//
//  Created by Adam Waxman on 2/6/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit
import CoreData

class CreateReminderViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    // Mark: - Properties
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    
    @IBOutlet weak var txtName: UITextField!
    
    @IBOutlet weak var txtReminderDate: UITextField!
    
    @IBOutlet weak var txtReminderType: UITextField!
    
    var reminderTypeOptions = ["Birthday", "Anniversary"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        txtReminderType.inputView = pickerView
        txtReminderType.text = "Birthday"

        self.title = "Add Reminder"
        
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
