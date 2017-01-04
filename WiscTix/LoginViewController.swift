//
//  LoginViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailTextField: SpecialTextField!
    @IBOutlet var passwordTextField: SpecialTextField!
    
    @IBOutlet var loginButton: UIButton!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.loginButton.layer.cornerRadius = 10
        self.navigationItem.title = "Login"
        // Do any additional setup after loading the view.
    }
    
 
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField as? SpecialTextField {
            text.setTextBorder(color: UIColor.red)
        }
    }

  
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField as? SpecialTextField {
            text.setTextBorder(color: UIColor.lightGray)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.passwordTextField.setTextBorder(color: UIColor.lightGray)
        self.emailTextField.setTextBorder(color: UIColor.lightGray)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.emailTextField) {
            self.resignFirstResponder()
            self.passwordTextField.becomeFirstResponder()
        } else if (textField == self.passwordTextField) {
            self.passwordTextField.resignFirstResponder()
            self.login()
        }
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        self.login()
    }
    
    
    func login() {
        guard emailTextField.text != "", passwordTextField.text != "" else {return}
        
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
            if error != nil {
                
                self.showError(errorMessage: error!.localizedDescription)
                
            } else if let user = user {
                
                if !user.isEmailVerified {
                    
                    self.showError(errorMessage: "Your email is not verified!")
                    
                } else {
                     UserDefaults.standard.set(true, forKey: "loggedIn")
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

class SpecialTextField: UITextField {
    var currentBorder: CALayer?
    func setTextBorder(color: UIColor) {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        if (currentBorder == nil) {
            self.layer.addSublayer(border)
            self.layer.masksToBounds = true
           
        } else {
            self.layer.replaceSublayer(self.currentBorder!, with: border)
        }
        self.currentBorder = border
    }
    
    
    
}
