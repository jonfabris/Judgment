//
//  Item.swift
//  Judgement
//
//  Created by Jon Fabris on 3/10/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
