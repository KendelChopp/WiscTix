//
//  ListingMakerViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/26/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ListingMakerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet var datePickerView: UIPickerView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceSlider: UISlider!
    
    var dateList = [Game]()
    var sport: Sport!
    var price = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView.delegate = self
        datePickerView.dataSource = self
        //getGames()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        getGames()
        self.datePickerView.selectRow(0, inComponent: 0, animated: true)
    }
    
    func getGames() {
        let ref = FIRDatabase.database().reference()
        self.dateList.removeAll()

    ref.child("sports").child(sport.rawValue.lowercased()).queryOrderedByKey().observeSingleEvent(of:.value, with: { (snapshot) in

            let gameList = snapshot.value as! [String : AnyObject]
            for (_, value) in gameList {

                if let date = value["date"] as? String, let opponent = value["opponent"] as? String, let time = value["time"] as? String {

                    let game = Game()
                    game.date = date
                    game.opponent = opponent
                    game.time = time
                    game.sport = self.sport
                    self.dateList.append(game)
                }
                
            }
            self.datePickerView.reloadAllComponents()
        })
        ref.removeAllObservers()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateList.count 
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dateList[row].date + " (" + dateList[row].opponent + ")"
    }

    @IBAction func cancelPressed(_ sender: Any) {
        
    }
  
    @IBAction func donePressed(_ sender: Any) {
        let sportString = sport.rawValue.lowercased()
        let opponent = self.dateList[self.datePickerView.selectedRow(inComponent: 0)].opponent as String
        let date = self.dateList[self.datePickerView.selectedRow(inComponent: 0)].date as String
        let price = self.priceLabel.text!
        let message = "Please confirm that you are selling a ticket for \(sportString) vs. \(opponent) on \(date) for \(price)."
        let actionSheet = UIAlertController(title: "Post Ticket", message: message, preferredStyle: .alert)
       
        actionSheet.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
           self.createListing()
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }

    @IBAction func priceChanged(_ sender: Any) {
        self.priceLabel.text = "$" + String(Int(self.priceSlider.value))
        self.price = Int(self.priceSlider.value)
    }
    
    func createListing() {
        let sportString = sport.rawValue
        let opponent = self.dateList[self.datePickerView.selectedRow(inComponent: 0)].opponent as String
        let date = self.dateList[self.datePickerView.selectedRow(inComponent: 0)].date as String
        let time = self.dateList[self.datePickerView.selectedRow(inComponent: 0)].time as String
        let today = NSDate()
    
        let calendar = NSCalendar.current
        let hour = calendar.component(.hour, from: today as Date)
        let minutes = calendar.component(.minute, from: today as Date)
        let day = calendar.component(Calendar.Component.day, from: today as Date)
        let month = calendar.component(.month, from: today as Date)
        let year = calendar.component(.year, from: today as Date)
        let userID = FIRAuth.auth()!.currentUser!.uid as String
        //let postID = "\(userID)-BREAK-\(day)-\(month)-\(year)-\(hour)-\(minutes)"
        let dateAdded = "\(day)-\(month)-\(year)-\(hour)-\(minutes)"
        let gameInfo: [String : Any] = ["date" : date, "opponent" : opponent, "price" : self.price, "time" : time, "sport" : sportString, "dateAdded" : dateAdded, "userID" : userID]
        let dataRef = FIRDatabase.database().reference()
        let postDataRef = dataRef.child("posts").childByAutoId()
        postDataRef.setValue(gameInfo)
       // dataRef.child("posts").child(postID).setValue(gameInfo)
        dataRef.child("users").child(userID).child("posts").childByAutoId().setValue(postDataRef.key)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar")
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
