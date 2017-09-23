//
//  InfoViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 1/9/17.
//  Copyright © 2017 Kendel Chopp. All rights reserved.
//
//  View controller to show information about WiscTix
//

import UIKit

class InfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func twitterPress(_ sender: Any) {
        let url = URL(string: "https://twitter.com/WiscTix")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    @IBAction func websitePress(_ sender: Any) {
        let url = URL(string: "https://wisctix.com")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func kendelChoppPress(_ sender: Any) {
        let url = URL(string: "http://kchopp.com")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }


    @IBAction func privacyPress(_ sender: Any) {
        let url = URL(string: "https://wisctix.com/privacypolicy")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    @IBAction func termsPress(_ sender: Any) {
        let url = URL(string: "https://wisctix.com/terms")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

}
