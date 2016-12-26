//
//  LoginViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginPressed(_ sender: Any) {
        guard emailTextField.text != "", passwordTextField.text != "" else {return}
        
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
            if error != nil {
                
                self.showError(errorMessage: error!.localizedDescription)
            
            } else if let user = user {
            
                if !user.isEmailVerified {
                    
                    self.showError(errorMessage: "Your email is not verified!")
                
                } else {
                
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar")
                    self.present(vc, animated: true, completion: nil)
                    
                }
            
            }
            
            
        })
    }
    
    
    
    
    func showError(errorMessage: String) {
        let alert = UIAlertController(title: "ERROR", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
