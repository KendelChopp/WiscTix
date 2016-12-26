//
//  Game.swift
//  WiscTix
//
//  Created by Kendel Chopp on 12/26/16.
//  Copyright © 2016 Kendel Chopp. All rights reserved.
//

import Foundation
import UIKit

class Game: NSObject {
    var sport: Sport!
    var date: String!
    var opponent: String!
    var time: String!
}

enum Sport: String {
    case basketball = "Basketball"
    case football = "Football"
    case hockey = "Hockey"
}
