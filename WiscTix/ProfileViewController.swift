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

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var titleItem: UINavigationItem!
    @IBOutlet var listingsTableView: UITableView!
    
    @IBOutlet var joinDateLabel: UILabel!
    @IBOutlet var numPostsLabel: UILabel!
    var userID: String!
    var listings = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listingsTableView.delegate = self
        self.listingsTableView.dataSource = self
        self.userID = FIRAuth.auth()?.currentUser?.uid
        self.loadTickets { (idList) in
            self.getListings(idList: idList)
        }
        self.getUserInfo()
        // Do any additional setup after loading the view.
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
     
        ref.child("users").child(self.userID).child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
         
            if let dict = snapshot.value as? [String : AnyObject] {
               
                for value in dict.values  {
                 
                    idList.append(value as! String)
                }
            }
           // idList.append(snapshot.key)
            completion(idList)
        })
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
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
                self.numPostsLabel.text = String(self.listings.count)
                self.listingsTableView.reloadData()
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
