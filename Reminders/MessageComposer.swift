//
//  MessageComposer.swift
//  Reminders
//
//  Created by Adam Waxman on 2/28/16.
//  Copyright © 2016 Waxman. All rights reserved.
//  From this tutorial: https://www.andrewcbancroft.com/2014/10/28/send-text-message-in-app-using-mfmessagecomposeviewcontroller-with-swift/
//

import Foundation
import MessageUI

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController(_ recipientNumber: [String]) -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = recipientNumber
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
