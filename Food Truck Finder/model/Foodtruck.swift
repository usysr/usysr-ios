//
//  User.swift
//
//  Created by Chazz Romeo on 12/15/19.
//  Copyright © 2020 Food Truck Finder Birmingham. All rights reserved.
//

import UIKit
import RealmSwift

class Foodtruck : Object {

    override static func primaryKey() -> String? {
        return "id"
    }
    
    static let ENTREE : String = "Entree"
    static let DESSERT : String = "Dessert"
    
    @objc dynamic var id: String = "" //UUID
    @objc dynamic var userId : String? = "" //ID given to user from firebase
    @objc dynamic var truckName: String? = "" //Name Given by Manager
    @objc dynamic var truckType: String? = "" //Dessert or Entree ONLY
    @objc dynamic var foodType: String? = "" //Jamaican, Southern
    
    //Future Attributes
    var images = List<String>() //List of images from firebase (urls that will be loaded)
    var documents = List<String>() //List of documents from firebase (urls that will be loaded)
    var addressOne: String? = "" // 2323 20th Ave South
    var addressTwo: String? = "" // 2323 20th Ave South
    var city: String? = "" // Birmingham
    var state: String? = "" // AL
    var zip: String? = "" // 35223
    
}

//func getFoodtrucksFromFirebase
//func saveFoodtruckToFirebase
//func removeFoodtruckFromFirebase

extension Foodtruck {
    func save() {
        if self.id != "" {
            let foodtruck = self
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(foodtruck)
            try! realm.commitWrite()
        }
    }
    
    static func findById(id: Int) -> Foodtruck? {
        let realm = try! Realm()
        if let foodtruck = realm.objects(Foodtruck.self).filter("id == \(id)").first {
            return foodtruck
        }
        
        return nil
    }
    
    func convertToDictionary() -> [String:Any] {
        var dic = [String:Any]()
        let foodtruck = self
        dic["id"] = foodtruck.id
        dic["truckType"] = foodtruck.truckType
        dic["truckName"] = foodtruck.truckName
        dic["foodType"] = foodtruck.foodType ?? ""
        dic["addressOne"] = foodtruck.addressOne ?? ""
        dic["addressTwo"] = foodtruck.addressTwo ?? ""
        dic["city"] = foodtruck.city ?? ""
        dic["state"] = foodtruck.state ?? ""
        dic["zip"] = foodtruck.zip ?? ""
        return dic
    }
}
    

extension Array where Element:Foodtruck {
    func saveAll(){
        let foodtrucks: [Foodtruck] = self
        if foodtrucks.count > 0 {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(foodtrucks)
            try! realm.commitWrite()
        }
    }
    
    func getindex(foodtruck_id: String) -> Int? {
        let foodtrucks: [Foodtruck] = self
        //resfresh item to the top
        let size = foodtrucks.count - 1
        if size >= 0 {
            for index in 0...foodtrucks.count {
                if foodtrucks[index].id == foodtruck_id {
                    return index
                }
            }
        }
        return nil
    }
}

class ParseFoodtruck {
    
    static func parseFoodtruck(map:NSObject) -> Foodtruck {
        let newTruck = Foodtruck()
        newTruck.id = map.value(forKey: "id") as? String ?? ""
        newTruck.userId = map.value(forKey: "userId") as? String
        newTruck.truckName = map.value(forKey: "truckName") as? String ?? ""
        newTruck.truckType = map.value(forKey: "truckType") as? String ?? ""
        newTruck.foodType = map.value(forKey: "foodType") as? String ?? ""
        newTruck.addressOne = map.value(forKey: "addressOne") as? String ?? ""
        newTruck.addressTwo = map.value(forKey: "addressTwo") as? String ?? ""
        newTruck.city = map.value(forKey: "city") as? String ?? ""
        newTruck.state = map.value(forKey: "state") as? String ?? ""
        newTruck.zip = map.value(forKey: "zip") as? String ?? ""
        return newTruck
    }
    
}
