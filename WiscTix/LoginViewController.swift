//
//  LoginViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//
//  View controller displayed when users with an account want to log in
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import OneSignal

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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        emailTextField.setTextBorder(color: UIColor.lightGray)
        passwordTextField.setTextBorder(color: UIColor.lightGray)
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
    
    /*
    * Send user to the privacy policy web page
    */
    @IBAction func privacyPressed(_ sender: Any) {
        let url = URL(string: "https://wisctix.com/privacypolicy")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    /*
     * Send user to the terms web page
     */
    @IBAction func termsPressed(_ sender: Any) {
        let url = URL(string: "https://wisctix.com/terms")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
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
    
    /*
     * Check the user's login info and log them in or tell them their info is wrong
     */
    func login() {
        guard emailTextField.text != "", passwordTextField.text != "" else {return}
        
        FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
            if error != nil {
                
                self.showError(errorMessage: error!.localizedDescription)
                
            } else if let user = user {
                
                if !user.isEmailVerified {
                    
                    self.showError(errorMessage: "Your email is not verified!")
                    
                } else {
                    OneSignal.idsAvailable({ (userID, pushToken) in
                        if (userID != nil) {
                            FIRDatabase.database().reference().child("users").child(user.uid).child("notification_id").child(userID!).setValue(userID)
                        }
                    })
                   /* if (OneSignal.app_id()) != nil {
                     
                    }*/
                     UserDefaults.standard.set(true, forKey: "loggedIn")
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar")
                    self.present(vc, animated: true, completion: nil)
                    
                }
                
            }
            
            
        })
    
    }
    
    /*
     * Alert the user as to a particular error
     */
    func showError(errorMessage: String) {
        let alert = UIAlertController(title: "ERROR", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//
// Class intended for making multiple of specially formatted text fields
//
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
