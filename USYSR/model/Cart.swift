//
//  User.swift
//
//  Created by Chazz Romeo on 12/15/19.
//  Copyright © 2020 Food Truck Finder Birmingham. All rights reserved.
//

import UIKit
import RealmSwift

class Cart : Object {

    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: String = "111" //Hardcoded to only allow one instance
    @objc dynamic var totalCost: String = "0.0" //Default to 0.0
    var spots = List<Spot>() //Spots in cart to buy
    
}


extension Cart {
    func save() {
        if self.id == "111" {
            let cart = self
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(cart)
            try! realm.commitWrite()
        }
    }
    
    
    
    static func getCart() -> Cart? {
        let realm = try! Realm()
        if let cart = realm.objects(Cart.self).filter("id == 111").first {
            return cart
        }
        return nil
    }
}
    

