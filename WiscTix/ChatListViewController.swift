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
        self.loadConversations{ (conversationID) in
            for id in conversationID {
             
                let ref = FIRDatabase.database().reference()
                ref.child("conversations").child(id).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                
                   
                    if let convo = snapshot.value as? [String : AnyObject] {
                     
                        let conversation = Conversation()
                        conversation.conversationID = id
                        if let name = convo["personOneName"] as? String{
                            conversation.name = name
                        }
                        
                        self.Conversations.append(conversation)
                        self.conversationTableView.reloadData()
                    }
                })
                ref.removeAllObservers()
            }
     
            
        
        }
        
        
        // Do any additional setup after loading the view.
    }

    
    func loadConversations(completion:@escaping (Array<String>) -> Void) -> Void {
        let ref = FIRDatabase.database().reference()
        let convoRef = ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("conversations")
        var conversationID = [String]()
     
        convoRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
          
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
               
                if let id = rest.value as? String{
                    conversationID.append(id)
                    
                }
            }
            completion(conversationID)
        })
    }

    
   /* func loadConversations() {
        let dispatchGroup = DispatchGroup() // We create the dispatch group
        
  
        let ref = FIRDatabase.database().reference()
        let convoRef = ref.child("users").child(FIRAuth.auth()!.currentUser!.uid).child("conversations")
        var conversationID = [String]()
        print(1)
        
        //dispatchGroup.enter()
        convoRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            let enumerator = snapshot.children
            print(2)
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
               print(3)
                if let id = rest.value as? String{
                    conversationID.append(id)
                    print(id)
                    //dispatchGroup.leave()
                }
            }
         
            
        })
        print(4)
       // dispatchGroup.wait()
        //ref.removeAllObservers()
        print("size: \(conversationID.count)")
    
        for id in conversationID {
         print(5)
           ref.child("conversations").queryEqual(toValue: id).observeSingleEvent(of: .value, with: { (snapshot) in
          print(6)
                if let convo = snapshot.value as? [String : AnyObject] {
              print(7)
                    let conversation = Conversation()
                    conversation.conversationID = id
                    conversation.name = "Temporary test name"
                    self.Conversations.append(conversation)
                }
           })
            ref.removeAllObservers()
        }
        print(8)
        self.conversationTableView.reloadData()
        
        
    }
    */
    @IBAction func logoutPressed(_ sender: Any) {
        try! FIRAuth.auth()?.signOut()
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
