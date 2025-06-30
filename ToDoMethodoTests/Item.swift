//
//  Item.swift
//  ToDoMethodoTests
//
//  Created by Jacques HU on 30/06/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    // MARK: - Exposed Properties

    var title: String = ""
    var itemDescription: String = ""

    var timestamp: Date

    // MARK: - Initializer

    init(title: String, itemDescription: String, timestamp: Date) {
        self.title = title
        self.itemDescription = itemDescription
        self.timestamp = timestamp
    }
}
