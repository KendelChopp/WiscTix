//
//  ChatListViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/26/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var conversationTableView: UITableView!
    
    var Conversations = [Conversation]()
    var refreshControl: UIRefreshControl!
    var userID: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userID = FIRAuth.auth()?.currentUser?.uid
        self.hidesBottomBarWhenPushed = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.conversationTableView.dataSource = self
        self.conversationTableView.delegate = self
        self.conversationTableView.rowHeight = 90
        
        self.loadConversations()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        conversationTableView.addSubview(refreshControl)
        
    }
    func refresh(sender:AnyObject) {
        self.loadConversations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ( self.conversationTableView.indexPathForSelectedRow != nil) {
          self.conversationTableView.deselectRow(at: self.conversationTableView.indexPathForSelectedRow!, animated: false)
        }
      
       // self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
      // self.tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = false
    }
    
//conversationID, senderId, senderDisplayName, senderName
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
        let convo = self.Conversations[(self.conversationTableView.indexPathForSelectedRow?.row)!]
        if (segue.identifier == "conversationSelect") {
            if let vc = segue.destination as? ChatViewController {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                //vc.conversationID = convo.conversationID
                vc.senderId = FIRAuth.auth()?.currentUser?.uid
                vc.senderDisplayName = convo.name
                vc.senderName = convo.name
               // vc.notificationID = convo.notificationID
                vc.conversation = convo
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.barTintColor = UIColor(red:0.77, green:0.02, blue:0.05, alpha:1.0)
        nav?.isTranslucent = false
        //nav?.backgroundColor = UIColor(red:0.77, green:0.02, blue:0.05, alpha:1.0)
        nav?.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

    }
    
    func loadConversations(){
        self.Conversations.removeAll()
        let ref = FIRDatabase.database().reference()
        let convoRef = ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("conversations")
        //var conversationID = [String]()
     
        convoRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
          
            while let nextObj = enumerator.nextObject() as? FIRDataSnapshot {
                if let rest = nextObj.value as? [String: AnyObject] {
                    if let id = rest["id"] as? String, let name = rest["name"] as? String, let read = rest["read"] as? Bool{
                        //conversationID.append(id)
                        let conversation = Conversation()
                        conversation.conversationID = id
                        conversation.name = name
                        conversation.isRead = read
                        conversation.userID = nextObj.key
                        conversation.recentMessage = ""
                        if let recent = rest["recentMessage"] as? String {
                            conversation.recentMessage = recent
                        }
                        ref.child("users").child(nextObj.key).child("notification_id").observe(.value, with: { (snap2) in
                            if let notID = snap2.value as? String {
                                conversation.notificationID = notID
                                 self.Conversations.append(conversation)
                            }
                            self.conversationTableView.reloadData()
                            if (self.refreshControl.isRefreshing) {self.refreshControl.endRefreshing()}
                        })
                        
                    }
                }
            }
            
        })
    }

    
  
    @IBAction func logoutPressed(_ sender: Any) {
        try! FIRAuth.auth()?.signOut()
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.conversationTableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
        cell.indentationLevel = 2
        cell.nameLabel.text = Conversations[indexPath.row].name
        cell.conversationLabel.text = Conversations[indexPath.row].recentMessage
        if (!Conversations[indexPath.row].isRead) {
            cell.readDotLabel.isHidden = false
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Conversations.count
       
    }
    

}
