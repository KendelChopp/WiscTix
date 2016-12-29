//
//  PostViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/26/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PostViewController: UIViewController {

    //var posterID: String!
    //var posterName: String!
    var userName: String!
    var tabBarC: UITabBarController!
    var listing: Listing!
    var userID: String?
    
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var posterLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var opponentLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var titleItem: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userID = FIRAuth.auth()?.currentUser?.uid
        self.getUserName()
        titleItem.title = self.listing.sport.rawValue
        self.posterLabel.text = self.listing.name
        self.timeLabel.text = self.listing.time
        self.dateLabel.text = self.listing.date
        self.opponentLabel.text = self.listing.opponent
        self.priceLabel.text = "$\(self.listing.price!)"
        self.deleteButton.layer.cornerRadius = 7
        if (listing.userID == self.userID) {
            self.deleteButton.isHidden = false
        }
        // Do any additional setup after loading the view.
    }

  
    @IBAction func composePressed(_ sender: Any) {
       // let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar") as! UITabBarController
     
        if (self.userID == self.listing.userID) {
            let actionSheet = UIAlertController(title: "Your Post", message: "You cannot create a conversation with yourself.", preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
            return
        }
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()!.currentUser!.uid
        let pOneName = self.userName
        let userRef = ref.child("users").child(uid).child("conversations")
     //   let otherUserRef = ref.child("users").child(self.listing.userID)
        
        let actionSheet = UIAlertController(title: "Create Conversation", message: "Would you like to messsage \(self.listing.name) about this ticket?", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            return
        }))
        self.present(actionSheet, animated: true, completion: nil)
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.listing.userID) {
                //No need to create new convo
            } else {

                let values = ["convoStarter" : uid]
                let idRef = ref.child("conversations").childByAutoId()
                idRef.setValue(values)

                let convoValuesOne = ["id" : idRef.key, "name" : self.listing.name]
                userRef.child(self.listing.userID).setValue(convoValuesOne)
                
                
                let convoValuesTwo = ["id" : idRef.key, "name" : pOneName]
                ref.child("users").child(self.listing.userID).child("conversations").child(uid).setValue(convoValuesTwo)
               
            }
        })
        
        self.tabBarC.selectedIndex = 1
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deletePost()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar")
            self.present(vc, animated: true, completion: nil)
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func deletePost() {
        let ref = FIRDatabase.database().reference()
        ref.child("posts").child(self.listing.postID).removeValue()
        ref.child("users").child(self.listing.userID).child("posts").child(self.listing.postID).removeValue()
    }
    
    func getUserName()  {
        let ref = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid)
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : AnyObject] {
                if let nameValue = value["name"] as? String {
                    self.userName = nameValue
                }
            }
        })
        
    }
}
