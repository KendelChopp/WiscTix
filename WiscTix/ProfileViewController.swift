//
//  ProfileViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/29/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import OneSignal

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet var titleItem: UINavigationItem!
    @IBOutlet var listingsTableView: UITableView!
    
    @IBAction func logoutPressed(_ sender: Any) {
        try! FIRAuth.auth()?.signOut()
        OneSignal.idsAvailable({ (userID, pushToken) in
            if (userID != nil) {
                FIRDatabase.database().reference().child("users").child(self.userID).child("notification_id").child(userID!).setValue(nil)
            }
        })
        UserDefaults.standard.set(false, forKey: "loggedIn")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeNavVC")
  
        self.present(vc, animated: true, completion: nil)
        
    }
    @IBOutlet var joinDateLabel: UILabel!
    @IBOutlet var numPostsLabel: UILabel!
    var userID: String!
    var listings = [Listing]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listingsTableView.delegate = self
        self.listingsTableView.dataSource = self
        self.userID = FIRAuth.auth()?.currentUser?.uid
        self.loadTickets { (idList) in
            self.getListings(idList: idList)
        }
        self.hidesBottomBarWhenPushed = true
        self.getUserInfo()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        listingsTableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }
    func refresh(sender:AnyObject) {
        self.loadTickets { (idList) in
            self.getListings(idList: idList)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false
        
        //nav?.backgroundColor = UIColor(red:0.77, green:0.02, blue:0.05, alpha:1.0)
        nav?.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    
    
    @IBAction func deleteAccountPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
            self.deleteAccount()
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
        
    }
    
    
    func deleteAccount() {
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        
        
        self.deletePosts()
        self.loadConversations { (convoList, userList) in
                self.deleteConversations(convoList: convoList, userList: userList, uid: uid!)
                ref.child("users").child(uid!).setValue(nil)
        }
        
        FIRAuth.auth()?.currentUser?.delete(completion: { (error) in
            if (error != nil) {
                let actionSheet = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                actionSheet.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(actionSheet, animated: true, completion: nil)
            }
        })
        UserDefaults.standard.set(false, forKey: "loggedIn")
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeNavVC")
        
        self.present(vc, animated: true, completion: nil)
    }
    
    func deleteConversations(convoList: [String], userList: [String], uid: String) {
        let ref = FIRDatabase.database().reference()
        for user in userList {
            ref.child("users").child(user).child("conversations").child(uid).setValue(nil)
        }
        for convo in convoList {
            ref.child("conversations").child(convo).setValue(nil)
        }
    }
    
    func deletePosts() {
        let ref = FIRDatabase.database().reference()
        for post in self.listings {
            ref.child("sports").child(post.sport.rawValue).child(post.date).child("posts").child(post.postID).setValue(nil)
            ref.child("posts").child(post.postID).setValue(nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ( self.listingsTableView.indexPathForSelectedRow != nil) {
            self.listingsTableView.deselectRow(at: self.listingsTableView.indexPathForSelectedRow!, animated: false)
        }
        
        // self.tabBarController?.tabBar.isHidden = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        // self.tabBarController?.tabBar.isHidden = true
        self.hidesBottomBarWhenPushed = false
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.listingsTableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! TicketListingCell
        let listing = listings[indexPath.row]
        cell.dateLabel.text = listing.date
        cell.opponentLabel.text = listing.opponent
        cell.postID = listing.postID
        cell.priceLabel.text = "$\(listing.price!)"
        cell.sportLabel.text = listing.sport.rawValue
        cell.sportImageView.image = UIImage(named: listing.sport.rawValue)
        if (listing.userID == self.userID) {
            cell.yourPostLabel.isHidden = false
        }
        return cell
    }
    func loadTickets(completion:@escaping (Array<String>) -> Void) -> Void {
        let ref = FIRDatabase.database().reference()
        var idList = [String]()
        self.listings.removeAll()
        ref.child("users").child(self.userID).child("posts").queryLimited(toLast: 25).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
         
            if let dict = snapshot.value as? [String : AnyObject] {
               
                for value in dict.values  {
                 
                    idList.append(value as! String)
                }
            }
           // idList.append(snapshot.key)
            completion(idList)
        })
    
    }
    
    func loadConversations(completion:@escaping (Array<String>, Array<String>) -> Void) -> Void {
        let ref = FIRDatabase.database().reference()
        var convoList = [String]()
        var userList = [String]()
        self.listings.removeAll()
        ref.child("users").child(self.userID).child("conversations").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let nextObj = enumerator.nextObject() as? FIRDataSnapshot {
                if let value = nextObj.value as? [String : AnyObject] {
                    convoList.append(value["id"] as! String)
                    userList.append(nextObj.key)
                }
            }
            completion(convoList, userList)
        })
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
        if (segue.identifier == "profilePostPickSegue") {
            if let vc = segue.destination as? PostViewController {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                vc.tabBarC = self.tabBarController
                let info = self.listings[(self.listingsTableView.indexPathForSelectedRow?.row)!]
                vc.listing = info
            }
        } else if (segue.identifier == "profileToInfo") {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
        }

    }
    func getListings(idList: [String]) {
    
        let ref = FIRDatabase.database().reference().child("posts")
      
        for id in idList {
          
            ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
 
                if let value = snapshot.value as? [String : AnyObject] {
             
                    let ticket = Listing()
                    ticket.postID = id
                    if let date = value["date"] as? String, let opponent = value["opponent"] as? String, let time = value["time"] as? String, let price = value["price"] as? Int, let sportString = value["sport"] as? String, let userID = value["userID"] as? String, let name = value["name"] as? String {
                       
                        let sport = Sport(rawValue: sportString)
                        ticket.sport = sport
                        ticket.date = date
                        ticket.price = price
                        ticket.opponent = opponent
                        ticket.time = time
                        ticket.userID = userID
                        ticket.name = name
                        self.listings.append(ticket)
                    }
                }
                self.listings.sort(by: {$0.postID > $1.postID})
                self.numPostsLabel.text = String(self.listings.count)
                self.listingsTableView.reloadData()
                if (self.refreshControl.isRefreshing) {self.refreshControl.endRefreshing()}
            })
        }
        
    }
    func getUserInfo()  {
        let ref = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid)
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
        
            if let values = snapshot.value as? [String : AnyObject] {
               
                if let nameValue = values["name"] as? String, let dateJoined = values["joinDate"] as? String {
                    self.titleItem.title = nameValue
                    self.joinDateLabel.text = dateJoined
                }
            }
        })
        
    }
    
    
}
