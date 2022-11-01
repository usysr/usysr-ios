//
//  User.swift
//
//  Created by Chazz Romeo on 12/15/19.
//  Copyright © 2020 Food Truck Finder Birmingham. All rights reserved.
//

import UIKit
import RealmSwift

class User : Object {

    override static func primaryKey() -> String? {
        return "uid"
    }
    
    @objc dynamic var uid: String = "" //Created by firebase
    @objc dynamic var name: String = "" //Firebase Standard
    @objc dynamic var email: String = "" //Firebase Standard
    @objc dynamic var phone: String = "" //Firebase Standard
    @objc dynamic var auth: String = "" //foodtruck_manager || location_manager
    /** Depracted for Foodtuck List/Object inside Session **/
    @objc dynamic var truckName: String = ""
    
}

extension User {
    func save() {
        if self.uid != "" {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(self, update: .modified)
            try! realm.commitWrite()
        }
    }
    
    func convertToDictionary() -> [String:Any] {
        var dic = [String:Any]()
        let user = self
        dic["uid"] = user.uid
        dic["name"] = user.name
        dic["auth"] = user.auth
        dic["email"] = user.email
        dic["phone"] = user.phone
        dic["truckName"] = user.truckName
        return dic
    }
    
    static func findById(id: Int) -> User? {
        let realm = try! Realm()
        if let user = realm.objects(User.self).filter("id == \(id)").first {
            return user
        }
        return nil
    }
}

//TODO:
class ParseUser {
    static func parseUser(value:NSDictionary) -> User {
        let user = User()
        //Be Safe?
        if let auth = value["auth"] as? String { user.auth = auth }
        if let uid = value["uid"] as? String { user.uid = uid }
        if let name = value["name"] as? String { user.name = name }
        if let email = value["email"] as? String { user.email = email }
        if let phone = value["phone"] as? String { user.phone = phone }
        if let truckName = value["truckName"] as? String { user.truckName = truckName }
        return user
    }
}

