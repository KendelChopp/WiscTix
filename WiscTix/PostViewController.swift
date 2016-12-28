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

    var posterID: String!
    var posterName: String!
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserName()
        // Do any additional setup after loading the view.
    }


    @IBAction func composePressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVc") as! ChatViewController
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()!.currentUser!.uid
        let pOneName = self.userName
        let userRef = ref.child("users").child(uid).child("conversations")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.posterID) {
                //No need to create new convo
                if let convoID = snapshot.childSnapshot(forPath: self.posterID).value as? String {
                    vc.conversationID = convoID
                }
            } else {
                //create new convo
                let values = ["personOne" : uid, "personTwo" : self.posterID, "personOneName" : pOneName ?? "ERROR", "personTwoName" : self.posterName]
                let idRef = ref.child("conversations").childByAutoId()
                idRef.setValue(values)
                userRef.child(self.posterID).setValue(idRef.key)
                ref.child("users").child(self.posterID).child("conversations").child(uid).setValue(idRef.key)
                vc.conversationID = idRef.key
            }
        })
        vc.senderId = posterID
        vc.senderDisplayName = "Kenny C"
        vc.senderName = "Kendel.example"
        self.present(vc, animated: true, completion: nil)
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
