//
//  PostViewController.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/26/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PostViewController: UIViewController {

    @IBOutlet var leftSide: UIView!
    @IBOutlet var rightSide: UIView!
    //var posterID: String!
    //var posterName: String!
    var userName: String!
    var tabBarC: UITabBarController!
    var listing: Listing!
    var userID: String?
    
    @IBOutlet var dashedView: UIView!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var posterLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var opponentLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userID = FIRAuth.auth()?.currentUser?.uid
        self.getUserName()
        self.navigationItem.title = self.listing.sport.rawValue
        self.posterLabel.text = self.listing.name
        self.timeLabel.text = self.listing.time
        self.dateLabel.text = self.listing.date
        self.opponentLabel.text = self.listing.opponent
        self.priceLabel.text = "$\(self.listing.price!)"
        self.deleteButton.layer.cornerRadius = 7
        if (listing.userID == self.userID) {
            self.deleteButton.isHidden = false
        }
        
       // self.drawTickets()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(compose))

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        self.drawTickets()
    }
  
    
    /*
     CAShapeLayer *shapeLayer = [CAShapeLayer layer];
     [shapeLayer setBounds:self.bounds];
     [shapeLayer setPosition:self.center];
     [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
     [shapeLayer setStrokeColor:[[UIColor blackColor] CGColor]];
     [shapeLayer setLineWidth:3.0f];
     [shapeLayer setLineJoin:kCALineJoinRound];
     [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
     [NSNumber numberWithInt:5],nil]];
     
     // Setup the path
     CGMutablePathRef path = CGPathCreateMutable();
     CGPathMoveToPoint(path, NULL, 10, 10);
     CGPathAddLineToPoint(path, NULL, 100,100);
     
     [shapeLayer setPath:path];
     CGPathRelease(path);
     
     [[self layer] addSublayer:shapeLayer];
     */
    
   
    func drawTickets() {
        let  path = UIBezierPath()
        
        let  p0 = CGPoint(x: self.dashedView.center.x - self.dashedView.frame.width / 2, y:
                              self.dashedView.center.y)
        path.move(to: p0)
    
        let  p1 = CGPoint(x: self.dashedView.center.x + self.dashedView.frame.width / 2, y:
                              self.dashedView.center.y)
        path.addLine(to: p1)

        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        let p = path.bounds.width
        let n = CGFloat(Int((p + 10) / 30))
        let g = Int(round((p-n*20)/(n-1)))
        
        
        shapeLayer.strokeColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0).cgColor
     
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineDashPattern = [20, NSNumber(value: g)]
        shapeLayer.lineWidth = 10.0
        
        self.view.layer.addSublayer(shapeLayer)
    }
    
    
    func compose(_ sender: Any) {
       // let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar") as! UITabBarController
     
        if (self.userID == self.listing.userID) {
            let actionSheet = UIAlertController(title: "Your Post", message: "You cannot create a conversation with yourself.", preferredStyle: .alert)
            actionSheet.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
            self.present(actionSheet, animated: true, completion: nil)
            return
        }
        
        let actionSheet = UIAlertController(title: "Create Conversation", message: "Would you like to messsage \(self.listing.name!) about this ticket?", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action) in
                self.composeConfirm()
        
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
            return
        }))
        self.present(actionSheet, animated: true, completion: nil)
       
    }
    
    func composeConfirm() {
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()!.currentUser!.uid
        let pOneName = self.userName
        let userRef = ref.child("users").child(uid).child("conversations")
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.hasChild(self.listing.userID) {
                //No need to create new convo
            } else {
                
                let values = ["convoStarter" : uid]
                let idRef = ref.child("conversations").childByAutoId()
                idRef.setValue(values)
                
                let convoValuesOne = ["id" : idRef.key, "name" : self.listing.name]
                userRef.child(self.listing.userID).setValue(convoValuesOne)
                
                
                let convoValuesTwo = ["id" : idRef.key, "name" : pOneName]
                ref.child("users").child(self.listing.userID).child("conversations").child(uid).setValue(convoValuesTwo)
                
            }
        })
        
        self.tabBarC.selectedIndex = 1
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Delete Post", message: "Are you sure you want to delete this post?", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.deletePost()
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "homeTabBar")
            self.present(vc, animated: true, completion: nil)
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func deletePost() {
        let ref = FIRDatabase.database().reference()
        ref.child("posts").child(self.listing.postID).removeValue()
        ref.child("users").child(self.listing.userID).child("posts").child(self.listing.postID).removeValue()
    }
    
    func getUserName()  {
        let ref = FIRDatabase.database().reference().child("users").child(FIRAuth.auth()!.currentUser!.uid)
        
        ref.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : AnyObject] {
                if let nameValue = value["name"] as? String {
                    self.userName = nameValue
                }
            }
        })
        
    }
}
