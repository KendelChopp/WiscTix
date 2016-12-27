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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conversationTableView.dataSource = self
        self.conversationTableView.delegate = self
        // Do any additional setup after loading the view.
    }

    
    func loadConversations() {
        let ref = FIRDatabase.database().reference()
        var conversationID = [String]()
        ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("conversations").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let id = snapshot.value as? String {
                conversationID.append(id)
            }
        })
        for id in conversationID {
           ref.child("conversations").queryEqual(toValue: id).observeSingleEvent(of: .value, with: { (snapshot) in
                if let convo = snapshot.value as? [String : AnyObject] {
                
                    let conversation = Conversation()
                    conversation.conversationID = id
                    conversation.name = "Temporary test name"
                    self.Conversations.append(conversation)
                }
           })
        }
        self.conversationTableView.reloadData()
        ref.removeAllObservers()
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.conversationTableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath) as! ConversationTableViewCell
        cell.nameLabel.text = Conversations[indexPath.row].name
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Conversations.count
    }
    

}
