//
//  Item.swift
//  VisualCents
//
//  Created by 小洛&卷卷 on 2026/1/17.
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
