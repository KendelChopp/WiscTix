//
//  WelcomeViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 1/3/17.
//  Copyright © 2017 Kendel Chopp. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    
    
    
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "WiscTix"
        loginButton.layer.borderWidth = 1
        loginButton.layer.borderColor = UIColor(red: 0.71, green: 0.00, blue: 0.05, alpha: 1.00).cgColor
        loginButton.layer.cornerRadius = 5
        signUpButton.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func kendelButtonPress(_ sender: Any) {
        let url = URL(string: "http://www.kchopp.com")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false
      

        //nav?.backgroundColor = UIColor(red:0.77, green:0.02, blue:0.05, alpha:1.0)
        nav?.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
    }
    
    
    
    
}
