//
//  ChatViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/26/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import FirebaseDatabase
import JSQMessagesViewController
import MessageUI
import OneSignal

class ChatViewController: JSQMessagesViewController, MFMailComposeViewControllerDelegate {

    //var conversationID: String!
    var conversation: Conversation!
    
    
    private var messageRef: FIRDatabaseReference!
    private var newMessageRefHandle: FIRDatabaseHandle?
    
   // var notificationID: String!
    
    var senderName: String? {
        didSet {
            title = senderName
        }
    }
      var messages = [JSQMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.inputToolbar.contentView.rightBarButtonItem.setTitleColor(UIColor(red:0.77, green:0.02, blue:0.05, alpha:1.0), for: UIControlState.normal)
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.messageRef = FIRDatabase.database().reference().child("conversations").child(self.conversation.conversationID).child("messages")
        self.observeMessages()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "flag"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(sendEmail))
        let ref = FIRDatabase.database().reference()
        ref.child("users").child(self.senderId).child("conversations").child(self.conversation.userID).child("read").setValue(true)
       
    }
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            ]
        
        itemRef.setValue(messageItem) // 3
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound() // 4
        
        finishSendingMessage() // 5
        
        OneSignal.postNotification(["contents": ["en": text!], "headings" : ["en" : self.senderDisplayName],"include_player_ids": self.conversation.notificationIDs!])
        let ref = FIRDatabase.database().reference()
    ref.child("users").child(conversation.userID).child("conversations").child(self.senderId).child("read").setValue(false)
    }
    
    func sendEmail() {
        let actionSheet = UIAlertController(title: "Report User", message: "Please confirm that you would like to report this user.", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Report", style: .destructive, handler: {(action) in
            self.sendReport()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            
        }))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func sendReport() {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients(["support@wisctix.com"])
        mailVC.setSubject("REPORT: \(self.senderName!)")
        mailVC.setMessageBody("Conversation ID: \(self.conversation.conversationID!)\nReport by: \(self.senderDisplayName!)\nReporter ID: \(self.senderId!)\nReason for report: ", isHTML: false)
        
        present(mailVC, animated: true, completion: nil)
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func observeMessages() {
        messageRef = FIRDatabase.database().reference().child("conversations").child(self.conversation.conversationID).child("messages")
        let messageQuery = messageRef.queryLimited(toLast:25)

        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
                self.addMessage(withId: id, name: name, text: text)
                let ref = FIRDatabase.database().reference()
                    ref.child("users").child(self.senderId).child("conversations").child(self.conversation.userID).child("read").setValue(true)
                ref.child("users").child(self.senderId).child("conversations").child(self.conversation.userID).child("recentMessage").setValue(text)
                ref.child("users").child(self.conversation.userID).child("conversations").child(self.senderId).child("recentMessage").setValue(text)
                self.finishReceivingMessage()
            } else {
                print("Error! Could not decode message data")
            }
        })
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
  
    

    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleRed())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    
    
}
