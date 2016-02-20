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
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch: \(error.localizedDescription)" )
        }
        
        tableView.rowHeight = 80
        
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
    
    func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    func handleTextNotification(notification: NSNotification) {
        print("Need to setup text handling")
    }
    
    func handleCallNotification(notification: NSNotification) {
        
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        let numberString = userInfo["phoneNumber"]
        if let number = numberString {
            callNumber(number)
            print("Calling: \(number)")
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reminder = fetchedResultsController.objectAtIndexPath(indexPath) as! Reminder
        let cell = tableView.dequeueReusableCellWithIdentifier("ReminderCell") as! ReminderTableViewCell
        
        cell.reminder = reminder
        
        let nextOccurence = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!)
        ReminderHelper.getDaysUntilReminder(nextOccurence)
        return cell
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
