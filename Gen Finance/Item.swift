//
//  Item.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 24/07/25.
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
