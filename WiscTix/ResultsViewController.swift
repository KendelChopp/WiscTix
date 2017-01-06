//
//  ResultsViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/31/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    
    
    @IBOutlet var resultsTableView: UITableView!
    var game: Game!
    var sortMethod: SortMethod!
    var userID: String!
    var tickets = [Listing]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        self.hidesBottomBarWhenPushed = true
        self.userID = FIRAuth.auth()?.currentUser?.uid
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        resultsTableView.addSubview(refreshControl)
        self.navigationItem.title = "Listings"
       self.loadTickets()
        // Do any additional setup after loading the view.
    }

    //resultsPickSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.hidesBottomBarWhenPushed = true
        if (segue.identifier == "resultsPickSegue") {
            
            if let vc = segue.destination as? PostViewController {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                
                vc.tabBarC = self.tabBarController
                
                let info = self.tickets[(self.resultsTableView.indexPathForSelectedRow?.row)!]
                vc.listing = info
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        if ( self.resultsTableView.indexPathForSelectedRow != nil) {
            self.resultsTableView.deselectRow(at: self.resultsTableView.indexPathForSelectedRow!, animated: false)
        }
        
        
    }
    
    func refresh(sender:AnyObject) {
        self.loadTickets()
    }
    
    
    func loadTickets() {
        let ref = FIRDatabase.database().reference().child("sports").child(game.sport.rawValue).child(game.date).child("posts")
        
       
        self.tickets.removeAll()
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
          
            let enumerator = snapshot.children
            while let nextObj = enumerator.nextObject() as? FIRDataSnapshot {
              
                if let posterID = nextObj.value as? String {
                    
                    if posterID != self.userID {
                        let postString = nextObj.key
                        let postsRef = FIRDatabase.database().reference().child("posts").child(postString)
                        
                        let query = postsRef.queryLimited(toLast: 25).queryOrderedByKey()
                        
                        let ticket = Listing()
                        ticket.postID = postString
                       
                        query.observeSingleEvent(of: .value, with: { (snap) in

                            if let value = snap.value as? [String : AnyObject] {
                                
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
                            if (self.sortMethod == SortMethod.price) {
                                self.tickets.sort(by: {$0.price < $1.price})
                            }
                            
                            self.resultsTableView.reloadData()
                            if (self.refreshControl.isRefreshing) {self.refreshControl.endRefreshing()}
                        })
                    
                    }
                }
            }
            

        })
        
    
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
        let cell = self.resultsTableView.dequeueReusableCell(withIdentifier: "listingCell", for: indexPath) as! TicketListingCell
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
    
    
    
    
    
}

enum SortMethod: String {

    case price = "Price"
    case date = "Date"
    
}
