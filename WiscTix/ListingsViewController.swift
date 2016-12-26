//
//  ListingsViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit

class ListingsViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutPressed(_ sender: Any) {
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
    
    
}
