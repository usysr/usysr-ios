//
//  User.swift
//
//  Created by Chazz Romeo on 12/15/19.
//  Copyright © 2020 Food Truck Finder Birmingham. All rights reserved.
//

import UIKit
import RealmSwift

class Location : Object {

    override static func primaryKey() -> String? {
        return "id"
    }
    
    @objc dynamic var id: String = "" //UUID
    @objc dynamic var locationName: String? = "" //Name Given by Manager
    @objc dynamic var addressOne: String? = "" // 2323 20th Ave South
    @objc dynamic var addressTwo: String? = "" // 2323 20th Ave South
    @objc dynamic var city: String? = "" // Birmingham
    @objc dynamic var state: String? = "" // AL
    @objc dynamic var zip: String? = "" // 35223
    @objc dynamic var typeOfPlace: String? = ""
    @objc dynamic var estPeople: String? = ""
    //Future
    @objc dynamic var details : String? = "" //Location Details
    var images = List<String>() //List of images from firebase (via urls)
    
}

extension Location {
    func save() {
        if self.id != "" {
            let location = self
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(location)
            try! realm.commitWrite()
        }
    }
    
    func convertToDictionary() -> [String:Any] {
        var dic = [String:Any]()
        let location = self
        dic["id"] = location.id
        dic["locationName"] = location.locationName
        dic["addressOne"] = location.addressOne
        dic["addressTwo"] = location.addressTwo
        dic["city"] = location.city
        dic["state"] = location.state
        dic["zip"] = location.zip
        dic["estPeople"] = location.estPeople
        dic["details"] = location.details
        dic["typeOfPlace"] = location.typeOfPlace
        return dic
    }
    
    static func findById(id: Int) -> Location? {
        let realm = try! Realm()
        if let location = realm.objects(Location.self).filter("id == \(id)").first {
            return location
        }
        
        return nil
    }
}
    

extension Array where Element:Location {
    func saveAll(){
        let spots: [Location] = self
        if spots.count > 0 {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(spots)
            try! realm.commitWrite()
        }
    }
    
}


class ParseLocation {
    
    static func parseLocation(map:NSObject) -> Location {
        let newLocation = Location()
        newLocation.id = map.value(forKey: "id") as? String ?? ""
        newLocation.locationName = map.value(forKey: "locationName") as? String
        newLocation.addressOne = map.value(forKey: "addressOne") as? String
        newLocation.addressTwo = map.value(forKey: "addressTwo") as? String
        newLocation.city = map.value(forKey: "city") as? String
        newLocation.state = map.value(forKey: "state") as? String
        newLocation.zip = map.value(forKey: "zip") as? String
        newLocation.estPeople = map.value(forKey: "estPeople") as? String
        newLocation.details = map.value(forKey: "details") as? String
        newLocation.typeOfPlace = map.value(forKey: "typeOfPlace") as? String
        return newLocation
    }
    
}
