//
//  Tips.swift
//  ListLoop
//
//  Created by Steve Parker on 11/2/24.
//

import Foundation
import TipKit

struct ResetTip: Tip {
    var title = Text("Reset List")
    
    var message: Text? = Text("Tap here to reset the list so all items are not checked.")
}
