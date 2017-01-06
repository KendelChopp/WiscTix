//
//  SignupViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/25/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import OneSignal

class SignupViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailTextField: SpecialTextField!
    @IBOutlet var passwordTextField: SpecialTextField!
    @IBOutlet var confirmPasswordTextField: SpecialTextField!
    
    @IBOutlet var signUpButton: UIButton!
    var dataRef: FIRDatabaseReference!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
         self.navigationController?.setNavigationBarHidden(false, animated: true)
         UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
        self.emailTextField.setTextBorder(color: UIColor.lightGray)
        self.passwordTextField.setTextBorder(color: UIColor.lightGray)
        self.confirmPasswordTextField.setTextBorder(color: UIColor.lightGray)
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
    
    @IBAction func termsPressed(_ sender: Any) {
        let url = URL(string: "https://wisctix.com/privacypolicy")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    

    
    @IBAction func privacyPressed(_ sender: Any) {
        let url = URL(string: "https://wisctix.com/terms")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        dataRef = FIRDatabase.database().reference()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        self.signUpButton.layer.cornerRadius = 10
        self.navigationItem.title = "Sign Up"
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == emailTextField) {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if (textField == passwordTextField) {
            passwordTextField.resignFirstResponder()
            confirmPasswordTextField.becomeFirstResponder()
        } else if (textField == confirmPasswordTextField) {
            confirmPasswordTextField.resignFirstResponder()
            self.signUp()
        }
        
        
        return true
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @IBAction func signUpPressed(_ sender: Any) {
        
        signUp()
        
    }
    
    func signUp() {
    
        //Check to make sure the credentials are legit
        
        if !(isValidEmail(testStr: emailTextField.text!)) {
            showError(errorMessage: "Please enter a valid email @wisc.edu.")
        }
        if !(isValidPassword(password: passwordTextField.text!)) {
            showError(errorMessage: "Please enter a password with 6-25 characters.")
        }
        if passwordTextField.text! != confirmPasswordTextField.text! {
            showError(errorMessage: "The passwords you entered do not match.")
        }
        var notID = "DEFAULT_ID"
        OneSignal.idsAvailable({ (notifierId, pushToken) in
            notID = notifierId!
        })
        var token = emailTextField.text!.components(separatedBy: "@")
        let name = token[0]
        //Create the user
        let today = NSDate()
        let calendar = NSCalendar.current
        let day = calendar.component(Calendar.Component.day, from: today as Date)
        let month = calendar.component(.month, from: today as Date)
        let year = calendar.component(.year, from: today as Date)
        FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
            
            if error != nil {
                
                self.showError(errorMessage: error!.localizedDescription)
                
            } else if let user = user {
                
                //let changeRequest = FIRAuth.auth()?.currentUser?.profileChangeRequest()
                //changeRequest?.displayName = name
                user.profileChangeRequest().displayName = name
                let userInfo: [String : Any] = ["uid" : user.uid, "name" : name, "joinDate" : "\(month)-\(day)-\(year)", "notification_id" : notID]
                self.dataRef.child("users").child(user.uid).setValue(userInfo)
                user.sendEmailVerification(completion: { (error) in
                    if (error != nil) {
                        print(error!.localizedDescription)
                    }
                })
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVc")
                self.navigationController?.popViewController(animated: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        })
        
    }
    
    
    func isValidPassword(password: String) -> Bool {
        if password.characters.count < 6 || password.characters.count > 25 {
            return false
        }
        return true
    }
    
    func isValidName(name: String) -> Bool {
        if name.characters.count < 2 || name.characters.count > 50 {
            return false
        }
        return true
        
    }
    
    func showError(errorMessage: String) {
        let alert = UIAlertController(title: "ERROR", message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        return true
        /*
            UNCOMMENT WHEN GOING INTO PRODUCTION
         
         let emailRegEx = "[A-Z0-9a-z._%+-]+@wisc.edu"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
         
         */
    }

}
