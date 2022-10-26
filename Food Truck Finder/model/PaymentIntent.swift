//
//  PaymentIntent.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 5/8/20.
//  Copyright © 2020 Adrenaline Life. All rights reserved.
//

import Foundation
import RealmSwift

class PaymentIntent : Object {

    @objc dynamic var amount: String = ""
    @objc dynamic var currency: String? = "usd"
    @objc dynamic var descr: String? = ""
    
    func buildJsonObject() -> [String:Any] {
        
        return [
            "amount":"\(self.amount)",
            "currency":"\(self.currency!)",
            "metadata": [
                "description": "\(self.descr!)"
            ]
        ]
        
    }
    
}

