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
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
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
        NotificationCenter.default.addObserver(self, selector: Selector("handleCallNotification:"), name: NSNotification.Name(rawValue: "callNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReminderTableViewController.handleTextNotification(_:)), name: NSNotification.Name(rawValue: "textNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReminderTableViewController.backgoundNofification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil);
        refresh()
    }
    
    // MARK: - IBActions
    
    @IBAction func addReminder(_ sender: UIBarButtonItem) {
        
    }
    
    // MARK: - Notification handling logic
    
    let messageComposer = MessageComposer()
    
    @objc func handleTextNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            let userInfo:Dictionary<String,String?> = notification.userInfo as! Dictionary<String,String?>
            let numberString = userInfo["phoneNumber"]
            
            // Make sure the device can send text messages
            if (self.messageComposer.canSendText()) {
                // Obtain a configured MFMessageComposeViewController
                let messageComposeVC = self.messageComposer.configuredMessageComposeViewController([numberString!!])
                
                self.present(messageComposeVC, animated: true, completion: nil)
            } else {
                // Let the user know if his/her device isn't able to send text messages
                print("There was an error")
            }
        }

    }
    
    func handleCallNotificationFromLaunch(_ notification: Notification) {
        
        let userInfo:Dictionary<String,String?> = notification.userInfo as! Dictionary<String,String?>
        let numberString = userInfo["phoneNumber"]
        if let number = numberString {
            DispatchQueue.main.async {
                self.callNumber(number!)
            }
        }
        
    }
    
    func callNumber(_ phoneNumber:String) {
        if let phoneCallURL:URL = URL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    func cancelNotification(_ idToDelete: String) {
        let notifications = UIApplication.shared.scheduledLocalNotifications!
        for notification in notifications {
            let userInfo:Dictionary<String,String?> = notification.userInfo as! Dictionary<String,String?>
            let reminderObjectId = userInfo["reminderObjectId"]
            if reminderObjectId! == idToDelete {
                //Cancelling local notification
                UIApplication.shared.cancelLocalNotification(notification)
                break;
            }
        }
    }
    
    func printNotifications() {
        let notifications = UIApplication.shared.scheduledLocalNotifications!
        print(notifications.count)
        for notification in notifications {
            // UIApplication.sharedApplication().cancelLocalNotification(notification)
            print(notification)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sectionCount = fetchedResultsController.sections?.count else {
            return 0
        }
        return sectionCount

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.name
        }
        
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionData = fetchedResultsController.sections?[section] else {
            return 0
        }
        return sectionData.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    func colorForIndex(_ index: Int) -> UIColor {
        let itemCount = fetchedResultsController.fetchedObjects!.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 2
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reminder = fetchedResultsController.object(at: indexPath) as! Reminder
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell") as! ReminderTableViewCell
        
        var rowNumber = indexPath.row
        for i in 0..<indexPath.section {
            rowNumber += self.tableView.numberOfRows(inSection: i)
        }
        cell.remainingBaseCircle.layer.borderColor = colorForIndex(rowNumber).cgColor
        
        cell.reminder = reminder
        
        let nextOccurence = ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!)
        ReminderHelper.getDaysUntilReminder(nextOccurence)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            view.backgroundView?.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
            view.textLabel!.backgroundColor = UIColor.clear
            view.textLabel!.textColor = UIColor(red: 0.65, green: 0.65, blue: 0.65, alpha: 1)
            view.textLabel!.font = UIFont.systemFont(ofSize: 13)
            
            // Add top and bottom border
            
            let borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).cgColor
            
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: view.frame.size.height - 1, width: view.frame.size.width, height: 1.0);
            bottomBorder.backgroundColor = borderColor
            view.layer.addSublayer(bottomBorder)
            
            let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: 1.0);
            topBorder.backgroundColor = borderColor
            view.layer.addSublayer(topBorder)
        }
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        default: break
        }
    }
    
    @objc func backgoundNofification(_ noftification:Notification){
        refresh();
    }
    
    func refresh() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let dataHelper = DataHelper(context: managedObjectContext)
        let reminders = dataHelper.getAllReminders() as! [Reminder]
        
        for reminder in reminders {
            reminder.remainingDays = ReminderHelper.getDaysUntilReminder(ReminderHelper.getNextOccurenceOfReminderDate(reminder.reminderDate!)) as NSNumber?
        }
        
        do {
            try self.context.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    // MARK: - Table view styling
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tableView.reloadData()
    }
    
    func updateNavBarStyle() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.42, green:0.14, blue:0.86, alpha:1.0)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let reminder = fetchedResultsController.object(at: indexPath) as! Reminder
            context.delete(reminder)
            cancelNotification(reminder.objectID.uriRepresentation().absoluteString)
            
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

    let reminderSegueIdentifier = "ShowReminderView"
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == reminderSegueIdentifier {
            if let destination = segue.destination as? ReminderViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    destination.reminder = fetchedResultsController.object(at: indexPath) as? Reminder
                }
            }
        }
    }

}
