//
//  SearchViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/31/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    
    
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var datePicker: UIPickerView!
    @IBOutlet var sportPicker: UIPickerView!
    @IBOutlet var sortMethodSegment: UISegmentedControl!
    
    var sportsList = [Sport]()
    var dateList = [Sport : [Game]]()
    var sport = Sport.basketball
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hidesBottomBarWhenPushed = true
        self.searchButton.layer.cornerRadius = 4
        self.datePicker.tag = 1
        self.sportPicker.tag = 0
        self.datePicker.delegate = self
        self.datePicker.dataSource = self
        self.sportPicker.delegate = self
        self.sportPicker.dataSource = self
        self.loadSports()
        
        // Do any additional setup after loading the view.
    }
    //date opponent time
    func loadSports() {
        let ref = FIRDatabase.database().reference().child("sports")
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let enumerator = snapshot.children
          
            while let nextObj = enumerator.nextObject() as? FIRDataSnapshot {
                if let sport = Sport(rawValue: nextObj.key) {
                    self.sportsList.append(sport)
                    var gameList = [Game]()
                    let gameEnumerator = nextObj.children
                    while let nextItem = gameEnumerator.nextObject() as? FIRDataSnapshot {
                    
                        if let nextValue = nextItem.value as? [String : AnyObject] {
                           
                            if let date = nextValue["date"] as? String, let opponent = nextValue["opponent"] as? String, let time = nextValue["time"] as? String {
                             
                                let game = Game()
                                game.sport = sport
                                game.date = date
                                game.opponent = opponent
                                game.time = time
                                gameList.append(game)
                                
                            }
                        }
                       

                    }
                    self.dateList.updateValue(gameList, forKey: sport)
                    
                }
            }
            self.sport = self.sportsList[0]
            self.datePicker.reloadAllComponents()
            self.sportPicker.reloadAllComponents()
            
        })
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 0 {
            self.sport = self.sportsList[row]
            self.datePicker.reloadAllComponents()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return sportsList[row].rawValue
        }
        return "\(dateList[self.sport]![row].date!) vs. \(dateList[self.sport]![row].opponent!)"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return sportsList.count
        }
        
        return dateList[sport]?.count ?? 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
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
        if (segue.identifier == "searchToTableSegue") {
            if let vc = segue.destination as? ResultsViewController {
                let backItem = UIBarButtonItem()
                backItem.title = "Back"
                navigationItem.backBarButtonItem = backItem
                vc.game = self.dateList[self.sport]?[self.datePicker.selectedRow(inComponent: 0)]
                vc.sortMethod = SortMethod.date
                if self.sortMethodSegment.selectedSegmentIndex == 0 {
                    vc.sortMethod = SortMethod.price
                }
            }
        }
    }
    
    
    
}
