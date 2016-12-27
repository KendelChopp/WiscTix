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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func composePressed(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatVc") as! ChatViewController
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()!.currentUser!.uid
        let userRef = ref.child("users").child(uid).child("conversations")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.posterID) {
                //No need to create new convo
                if let convoID = snapshot.childSnapshot(forPath: self.posterID).value as? String {
                    vc.conversationID = convoID
                }
            } else {
                //create new convo
                let values = ["personOne" : uid, "personTwo" : self.posterID]
                let idRef = ref.child("conversations").childByAutoId()
                idRef.setValue(values)
                userRef.child(self.posterID).setValue(idRef.key)
                ref.child("users").child(self.posterID).child("conversations").child(uid).setValue(idRef.key)
                vc.conversationID = idRef.key
            }
        })
        vc.senderId = posterID
        vc.senderDisplayName = "Kenny C"
    
        self.present(vc, animated: true, completion: nil)
    }

}
