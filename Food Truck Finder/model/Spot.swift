//
//  User.swift
//
//  Created by Chazz Romeo on 12/15/19.
//  Copyright © 2020 Food Truck Finder Birmingham. All rights reserved.
//

import UIKit
import RealmSwift

class Spot : Object {

    override static func primaryKey() -> String? {
        return "id"
    }
    
    static let LUNCH_TIME : String = "11AM-2PM"
    static let DINNER_TIME : String = "5PM-8PM"
    
    static let PRICE : String = "5.00"
    
    static let AVAILABLE : String = "available"
    static let PENDING : String = "pending"
    static let BOOKED : String = "booked"
    
    static let ENTREE : String = "Entree"
    static let DESSERT : String = "Dessert"
    
    @objc dynamic var id: String? = ""
    @objc dynamic var addressOne: String? = "" // 2323 20th Ave South
    @objc dynamic var addressTwo: String? = "" // 2323 20th Ave South
    @objc dynamic var city: String? = "" // Birmingham
    @objc dynamic var state: String? = "" // AL
    @objc dynamic var zip: String? = "" // 35223
    @objc dynamic var parkingInfo: String? = "" // "Park on the third spot to the right"
    @objc dynamic var date: String? = "" // 10 Dec 2019
    @objc dynamic var foodType: String? = "" //Entree, Dessert. . .
    @objc dynamic var mealTime: String? = ""  //Breakfast, Lunch or Dinner?
    @objc dynamic var estPeople: String? = "" //Estimate Number of People
    //TODO: PRICE DEFAULT WILL REPLACED WITH ADMIN SETTINGS IN FIREBASE
    @objc dynamic var price: String? = "" //Assigned Price to Spot
    @objc dynamic var spotManager: String? = "" //Creators Display Name
    @objc dynamic var assignedTruckUid : String? = "" //FoodTruck who buys Spot
    @objc dynamic var assignedTruckName : String? = "" //FoodTruck who buys Spot
    @objc dynamic var locationName: String? = "" //Custom Name Made by Creator
    @objc dynamic var locationUUID: String? = "" //Custom Name Made by Creator
    @objc dynamic var status: String? = Spot.AVAILABLE //Custom Name Made by Creator
    
    func parseTime(str:String) -> String {
        //11-2
        if str.lowercased() == "lunch" {
            return Spot.LUNCH_TIME
        }
        //5-8
        else if str.lowercased() == "dinner" {
            return Spot.DINNER_TIME
        }
        else {
            return str
        }
    }
    
}

extension Spot {
    func save() {
        if self.id != "" {
            let spot = self
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(spot)
            try! realm.commitWrite()
        }
    }
    
    static func findById(id: Int) -> Spot? {
        let realm = try! Realm()
        if let spot = realm.objects(Spot.self).filter("id == \(id)").first {
            return spot
        }
        
        return nil
    }
    
    func parseMealTime(str:String) {
        //11-2
        if str.lowercased() == "lunch" {
            self.mealTime = Spot.LUNCH_TIME
        }
        //5-8
        else if str.lowercased() == "dinner" {
            self.mealTime = Spot.DINNER_TIME
        }
        else {
            self.mealTime = str
        }
    }
    
    func convertToDictionary() -> [String:Any] {
        var dic = [String:Any]()
        let spot = self
        dic["id"] = spot.id
        dic["locationName"] = spot.locationName
        dic["locationUUID"] = spot.locationUUID
        dic["addressOne"] = spot.addressOne
        dic["addressTwo"] = spot.addressTwo
        dic["city"] = spot.city
        dic["state"] = spot.state
        dic["zip"] = spot.zip
        dic["parkingInfo"] = spot.parkingInfo
        dic["estPeople"] = spot.estPeople
        dic["mealTime"] = spot.mealTime
        dic["foodType"] = spot.foodType
        dic["date"] = spot.date
        dic["spotManager"] = spot.spotManager
        dic["price"] = spot.price
        dic["status"] = spot.status
        dic["assignedTruckUid"] = spot.assignedTruckUid
        dic["assignedTruckName"] = spot.assignedTruckName
        return dic
    }
}
    
class ParseSpot {
    
    static func parseSpot(map:NSObject) -> Spot {
        let newSpot = Spot()
        newSpot.id = map.value(forKey: "id") as? String
        newSpot.locationName = map.value(forKey: "locationName") as? String
        newSpot.locationUUID = map.value(forKey: "locationUUID") as? String
        newSpot.addressOne = map.value(forKey: "addressOne") as? String
        newSpot.addressTwo = map.value(forKey: "addressTwo") as? String
        newSpot.city = map.value(forKey: "city") as? String
        newSpot.state = map.value(forKey: "state") as? String
        newSpot.zip = map.value(forKey: "zip") as? String
        newSpot.parkingInfo = map.value(forKey: "parkingInfo") as? String
        newSpot.date = map.value(forKey: "date") as? String
        newSpot.spotManager = map.value(forKey: "spotManager") as? String
        newSpot.parseMealTime(str: (map.value(forKey: "mealTime") as! String))
        newSpot.foodType = map.value(forKey: "foodType") as? String
        newSpot.estPeople = map.value(forKey: "estPeople") as? String
        newSpot.assignedTruckUid = map.value(forKey: "assignedTruckUid") as? String
        newSpot.assignedTruckName = map.value(forKey: "assignedTruckName") as? String
        newSpot.status = map.value(forKey: "status") as? String
        newSpot.price = map.value(forKey: "price") as? String
        return newSpot
    }
    
}
