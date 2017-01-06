//
//  ConversationTableViewCell.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/26/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    var conversationID: String!
    
    @IBOutlet var conversationLabel: UILabel!
    @IBOutlet var readDotLabel: UILabel!
    
}
