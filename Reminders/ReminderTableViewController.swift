//
//  ReminderTableViewController.swift
//  Reminders
//
//  Created by Adam Waxman on 2/2/16.
//  Copyright © 2016 Waxman. All rights reserved.
//

import UIKit
import CoreData

class ReminderTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // Mark: - Properties
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    var fetchedResultsController: NSFetchedResultsController!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Reminder")
        let fetchSort = NSSortDescriptor(key: "remainingDays", ascending: true)
        fetchRequest.sortDescriptors = [fetchSort]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: "section",
            cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)" )
        }
        
        tableView.rowHeight = 80
        
        updateNavBarStyle()
        
        // Adding notification center observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleCallNotification:", name: "callNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleTextNotification:", name: "textNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "backgoundNofification:", name: UIApplicationWillEnterForegroundNotification, object: nil);
        refresh()
    }
    
    // MARK: - IBActions
    
    @IBAction func addReminder(sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Notification handling logic
    
    let messageComposer = MessageComposer()
    
    func handleTextNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) {
            let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
            let numberString = userInfo["phoneNumber"]
            
            // Make sure the device can send text messages
            if (self.messageComposer.canSendText()) {
                // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = self.messageComposer.configuredMessageComposeViewController([numberString!])
                
                self.presentViewController(messageComposeVC, animated: true, completion: nil)
            } else {
                // Let the user know if his/her device isn't able to send text messages
                print("There was an error")
            }
        }

    }
    
    func handleCallNotificationFromLaunch(notification: NSNotification) {
        
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let numberString = userInfo["phoneNumber"]
        if let number = numberString {
            dispatch_async(dispatch_get_main_queue()) {
                self.callNumber(number)
            }
        }
        
    }
    
    func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    func cancelNotification(idToDelete: String) {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        for notification in notifications {
            let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
            let reminderObjectId = userInfo["reminderObjectId"]
            if reminderObjectId == idToDelete {
                //Cancelling local notification
                UIApplication.sharedApplication().cancelLocalNotification(notification)
                break;
            }
        }
    }
    
    func printNotifications() {
        let notifications = UIApplication.sharedApplication().scheduledLocalNotifications!
        print(notifications.count)
        for notification in notifications {
            // UIApplication.sharedApplication().cancelLocalNotification(notification)
            print(notification)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        return sectionCount

    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = fetchedResultsController.fetchedObjects!.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 2
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell") as! ReminderTableViewCell
        
        var rowNumber = indexPath.row
        for i in 0..<indexPath.section {
            rowNumber += self.tableView.numberOfRowsInSection(i)
        }
        cell.remainingBaseCircle.layer.borderColor = colorForIndex(rowNumber).CGColor
        
        cell.reminder = reminder
        
        let nextOccurence = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!)
        ReminderHelper.getDaysUntilReminder(nextOccurence)
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundView?.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
            view.textLabel!.backgroundColor = UIColor.clearColor()
            view.textLabel!.textColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1)
            view.textLabel!.font = UIFont.systemFontOfSize(13)
            
            // Add top and bottom border
            
            let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
            
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRectMake(0.0, view.frame.size.height - 1, view.frame.size.width, 1.0);
            bottomBorder.backgroundColor = borderColor
            view.layer.addSublayer(bottomBorder)
            
            let topBorder = CALayer()
            topBorder.frame = CGRectMake(0.0, 0.0, view.frame.size.width, 1.0);
            topBorder.backgroundColor = borderColor
            view.layer.addSublayer(topBorder)
        }
        
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default: break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
        default: break
        }
    }
    
    func backgoundNofification(noftification:NSNotification){
        refresh();
    }
    
    func refresh() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let dataHelper = DataHelper(context: managedObjectContext)
        let reminders = dataHelper.getAllReminders() as! [Reminder]
        
        for reminder in reminders {
            reminder.remainingDays = ReminderHelper.getDaysUntilReminder(ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!))
        }
        
        do {
            try self.context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    // MARK: - Table view styling
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    func updateNavBarStyle() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.42, green:0.14, blue:0.86, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
            context.deleteObject(reminder)
            cancelNotification(reminder.objectID.URIRepresentation().absoluteString)
            
            do {
                try context.save()
            } catch let error as NSError {
                print("Error saving context after deleting: \(error.localizedDescription)")
            }
        default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
