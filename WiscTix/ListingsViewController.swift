//
//  ListingsViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var ticketsTableView: UITableView!
    
    var tickets = [Listing]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ticketsTableView.delegate = self
        ticketsTableView.dataSource = self
        self.loadTickets()
        // Do any additional setup after loading the view.
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
        return cell
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
    }
    
    func loadTickets() {
        let ref = FIRDatabase.database().reference()
        ref.child("posts").queryOrdered(byChild: "dateAdded").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value is NSNull) {return}
            let postList = snapshot.value as! [String : AnyObject]
            for (key, value) in postList {
                let ticket = Listing()
                ticket.postID = key
                if let date = value["date"] as? String, let opponent = value["opponent"] as? String, let time = value["time"] as? String, let price = value["price"] as? Int, let sportString = value["sport"] as? String, let userID = value["userID"] as? String {
                    let sport = Sport(rawValue: sportString)
                    ticket.sport = sport
                    ticket.date = date
                    ticket.price = price
                    ticket.opponent = opponent
                    ticket.time = time
                    ticket.userID = userID
                    self.tickets.append(ticket)
                }
            }
            self.ticketsTableView.reloadData()
        })
        ref.removeAllObservers()
    }
    
  
    @IBAction func addPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Sport", message: "What sport do you have a ticket for?", preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: "Basketball", style: .default, handler: { (action) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listingMakerVc") as! ListingMakerViewController
            vc.sport = Sport.basketball
            self.present(vc, animated: true, completion: nil)
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "postVc") as! PostViewController
        vc.posterID = self.tickets[indexPath.row].userID
        self.present(vc, animated: true, completion: nil)
    }
    
    
    
    
    
    
}
