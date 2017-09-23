//
//  ListingsViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//
//  View controller which displays all available tickets
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class ListingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var ticketsTableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var userID: String!
    var tickets = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ticketsTableView.delegate = self
        ticketsTableView.dataSource = self
        self.hidesBottomBarWhenPushed = true
        self.loadTickets()
        self.navigationController?.title = "Listings"
        self.userID = FIRAuth.auth()?.currentUser?.uid
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        ticketsTableView.addSubview(refreshControl)
    }

    func refresh(sender:AnyObject) {
        self.loadTickets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ( self.ticketsTableView.indexPathForSelectedRow != nil) {
            self.ticketsTableView.deselectRow(at: self.ticketsTableView.indexPathForSelectedRow!, animated: false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tickets.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 111
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ticketsTableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! TicketListingCell
        let listing = tickets[indexPath.row]
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
    
    @IBAction func logoutPressed(_ sender: Any) {
       try! FIRAuth.auth()?.signOut()
        UserDefaults.standard.set(false, forKey: "loggedIn")
    }
    
    /*
     * Get a list of the tickets from Firebase
     */
    func loadTickets() {
      self.tickets.removeAll()
        let ref = FIRDatabase.database().reference()
        ref.child("posts").queryLimited(toLast: 25).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
          
            if (snapshot.value is NSNull) {return}
          
            let postList = snapshot.value as! [String : AnyObject]
            for (key, value) in postList {
              
                let ticket = Listing()
                ticket.postID = key

                if let date = value["date"] as? String, let opponent = value["opponent"] as? String, let time = value["time"] as? String, let price = value["price"] as? Int, let sportString = value["sport"] as? String, let userID = value["userID"] as? String, let name = value["name"] as? String {
                    
                    let sport = Sport(rawValue: sportString)
                    ticket.sport = sport
                    ticket.date = date
                    ticket.price = price
                    ticket.opponent = opponent
                    ticket.time = time
                    ticket.userID = userID
                    ticket.name = name
                    self.tickets.append(ticket)
                }
            }
            self.tickets.sort(by: {$0.postID > $1.postID})
            self.ticketsTableView.reloadData()
            if (self.refreshControl.isRefreshing) {self.refreshControl.endRefreshing()}
        })
        
        ref.removeAllObservers()
    }
    
    /*
     * Send user to the ListingsMakerViewController when creating a new ticket listing
     */
    func newPost(completion:@escaping (UIAlertController) -> Void) -> Void {
        let actionSheet = UIAlertController(title: "Sport", message: "What sport do you have a ticket for?", preferredStyle: .actionSheet)
        
        let ref = FIRDatabase.database().reference().child("sports")
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
            while let nextObj = enumerator.nextObject() as? FIRDataSnapshot {
                if let sport = Sport(rawValue: nextObj.key) {
                    actionSheet.addAction(UIAlertAction(title: sport.rawValue, style: .default, handler: { (action) in
                        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listingMakerVc") as! ListingMakerViewController
                        vc.sport = sport
                        self.present(vc, animated: true, completion: nil)
                    }))
                }
            }
            completion(actionSheet)
        })
        /*actionSheet.addAction(UIAlertAction(title: "Basketball", style: .default, handler: { (action) in
         let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listingMakerVc") as! ListingMakerViewController
         vc.sport = Sport.basketball
         self.present(vc, animated: true, completion: nil)
         }))*/
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    }
    
    @IBAction func addPostPressed(_ sender: Any) {
        self.newPost { (vc) in
            vc.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            self.present(vc, animated: true, completion: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false
       
        //nav?.backgroundColor = UIColor(red:0.77, green:0.02, blue:0.05, alpha:1.0)
        nav?.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
        if (segue.identifier == "postPickSegue") {
           
            if let vc = segue.destination as? PostViewController {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                
                vc.tabBarC = self.tabBarController
                
                let info = self.tickets[(self.ticketsTableView.indexPathForSelectedRow?.row)!]
                vc.listing = info
            }
        }
    }
    
}
