//
//  Session.swift
//
//  Created by Chazz Romeo on 12/15/19.
//  Copyright © 2020 Foodtruck Finder Birmingham. All rights reserved.
//

import UIKit
import RealmSwift

class Session: Object {
    
    override static func primaryKey() -> String? {
        return "sessionId"
    }

    @objc dynamic var sessionId: Int = 1 //Hardcoded to only allow one session
    @objc dynamic var user: User? //Our Current User Object
    var locations = List<Location>() //For Location Managers to save Location Objects
    var foodtrucks = List<Foodtruck>() //For Foodtruck Managers to save Foodtruck Objects
    var spots = List<Spot>() //For Both to create or save spots.
    
}


extension Session {
    
    func save() {
        let realm = try! Realm()
        if let _ = realm.objects(Session.self).first {
            realm.beginWrite()
            realm.add(self, update: .modified)
            try! realm.commitWrite()
        }
    }
    
    static func calculateTotalCost(spots:List<Spot>) -> String? {
        var total : Double = 0.00
        print("Total Cost Before -> \(total)")
        for spot in spots {
            guard let safeSpotPrice = spot.price else {
                return nil
            }
            guard let finalSpotPrice = Double(safeSpotPrice) else {
                return nil
            }
            total = total + finalSpotPrice
        }
        print("Total Cost After -> \(total)")
        return String(total) + "0"
    }
    
    //-> Get Current Session!
    static func getInstance() -> Session? {
        
        let realm = try! Realm()
        let session = realm.objects(Session.self).first
        
        if let sess = session {
            return sess
        }
        
        return nil
    }
    
    //
    static func getUser() -> User? {
        
        let realm = try! Realm()
        let session = realm.objects(Session.self).first
        
        if let user = session?.user {
            return user
        }
        
        return nil
    }
    
    //-> Is User Logged In? (Does a User Exist?)
    static func isLogged() -> Bool {
        let realm = try! Realm()
        let sessions = realm.objects(Session.self)
        guard let session = sessions.first else { return false }
        if (session.user != nil) {
            return true
        }
        return false
    }
    
    //-> Add Foodtruck
    static func addFoodTruck(truck: Foodtruck) {
        
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            for sessTruck in session.foodtrucks {
                if sessTruck.id == truck.id {
                    Session.updateFoodtruck(truck: truck)
                    return
                }
            }
            realm.beginWrite()
            session.foodtrucks.removeAll()
            session.foodtrucks.append(truck)
            realm.add(session, update: .modified)
            try! realm.commitWrite()
        }
    }
    
    //-> Update Foodtruck
    static func updateFoodtruck(truck: Foodtruck) {
        
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            
            if session.foodtrucks.isEmpty {
                Session.addFoodTruck(truck: truck)
            } else {
                for sessTruck in session.foodtrucks {
                    if sessTruck.id == truck.id {
                        realm.beginWrite()
                        
                        sessTruck.truckName = truck.truckName
                        sessTruck.truckType = truck.truckType
                        sessTruck.foodType = truck.foodType
                                           
                        realm.add(session, update: .modified)
                        try! realm.commitWrite()
                    }
                }
            }
        }
    }
    
    //-> Add Location
    static func addUpdateLocation(location: Location) {
        do {
            let realm = try Realm()
            if let session = realm.objects(Session.self).first {
                
                for loc in session.locations {
                    if loc.id == location.id {
                        updateLocation(location: location)
                        return
                    }
                }
                
                realm.beginWrite()
                session.locations.append(location)
                realm.add(session, update: .modified)
                try! realm.commitWrite()
            }
        } catch let error as NSError {
            print("Uh oh, error while adding location to session", error)
        }
        
    }
    
    //-> Update Location
    private static func updateLocation(location: Location) {
        
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            for loc in session.locations {
                
                if loc.id != location.id {
                    continue
                }
                
                realm.beginWrite()
                
                loc.locationName = location.locationName
                loc.addressOne = location.addressOne
                loc.addressTwo = location.addressTwo
                loc.city = location.city
                loc.state = location.state
                loc.zip = location.zip
                loc.estPeople = location.estPeople
                loc.details = location.details
                
                realm.add(session, update: .modified)
                try! realm.commitWrite()
                return
            }
            
        }
        
    }
    
    //Add Spot to current Session
    static func addSpotToSession(spot: Spot) {
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            for s in session.spots {
                if s.id == spot.id {
                    return
                }
            }
            realm.beginWrite()
            if let existingSpot = realm.object(ofType: Spot.self, forPrimaryKey: spot.id) {
                session.spots.append(existingSpot)
                realm.add(session, update: .modified)
                try! realm.commitWrite()
            } else {
                session.spots.append(spot)
                realm.add(session, update: .modified)
                try! realm.commitWrite()
            }
        }
            
    }
    
    //-> Remove Spot from current Cart
    static func removeSpotFromCart(spot: Spot) {
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            realm.beginWrite()
            for (i,num) in session.spots.enumerated().reversed() {
                if num.id == spot.id {
                    session.spots.remove(at: i)
                    realm.add(session, update: .modified)
                    try! realm.commitWrite()
                    return
                }
            }
        }
    }
    
    //-> Update Spot For *Pending/Available*
    static func updateSpotForFirebase(spot: Spot, status: String, assignedTruckUid: String, assignedTruckName: String)  -> Spot? {
        
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            
            for s in session.spots {
                if s.id == spot.id {
                    realm.beginWrite()
                    s.assignedTruckUid = assignedTruckUid
                    s.assignedTruckName = assignedTruckName
                    s.status = status
                    realm.add(session, update: .modified)
                    try! realm.commitWrite()
                    return s
                }
            }
        }
        return nil
    }
    
    //-> Update Spot For *Booking*
    static func updateSpotForFirebase(spot: Spot, status: String)  -> Spot? {
        
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            
            for s in session.spots {
                if s.id == spot.id {
                    realm.beginWrite()
                    s.status = status
                    realm.add(session, update: .modified)
                    try! realm.commitWrite()
                    return s
                }
            }
        }
        return nil
    }
    
    //-> Update User Firebase Database Profile
    static func updateUserForFirebase(updatedUser: User)  -> User? {
        let realm = try! Realm()
        if let realmUser = realm.objects(User.self).first {
            if realmUser.uid == updatedUser.uid {
                realm.beginWrite()
                realmUser.name = updatedUser.name
                realmUser.email = updatedUser.email
                realmUser.phone = updatedUser.phone
                realmUser.truckName = updatedUser.truckName
                realm.add(realmUser, update: .modified)
                try! realm.commitWrite()
                return realmUser
            }
            
        }
        return nil
    }
    
    //For User Profile Update
    static func updateUser(updatedUser: User) {
        
        let realm = try! Realm()
        if let realmUser = realm.objects(User.self).first {
            if realmUser.uid == updatedUser.uid {
                realm.beginWrite()
                realmUser.auth = updatedUser.auth
                realmUser.name = updatedUser.name
                realmUser.email = updatedUser.email
                realmUser.phone = updatedUser.phone
                realmUser.truckName = updatedUser.truckName
                realm.add(realmUser, update: .modified)
                try! realm.commitWrite()
            }
        }
    }
    
    //For User Profile Update
    static func saveUser(user: User) {
        
        let realm = try! Realm()
        if var realmUser = realm.objects(User.self).first {
            realm.beginWrite()
            realmUser = user
            realm.add(realmUser, update: .modified)
            try! realm.commitWrite()
        }
        
        if let realmSession = realm.objects(Session.self).first {
            realm.beginWrite()
            realmSession.user = user
            realmSession.save()
            try! realm.commitWrite()
        }
    }
    
    static func removeAllSpots() {
        
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            
            let spots = session.spots
            realm.beginWrite()
            spots.removeAll()
            realm.add(session, update: .modified)
            try! realm.commitWrite()
        }
            
    }
    
    //-> Remove all Location Objects from current Session (for reloading)
    static func removeAllLocationsFromSession() {
        
        let realm = try! Realm()
        if let session = realm.objects(Session.self).first {
            realm.beginWrite()
            session.locations.removeAll()
            session.locations = List<Location>()
            realm.add(session, update: .modified)
            try! realm.commitWrite()
        }
    }
    
    static func removeRealmLocationObject() {
        let realm = try! Realm()
        let item = realm.objects(Location.self)
        realm.beginWrite()
        realm.delete(item)
        try! realm.commitWrite()
    }
    
    //-> Remove all Foodtruck Objects from current Session (for reloading)
    static func removeAllFoodtrucksFromSession() {
       
       let realm = try! Realm()
       if let session = realm.objects(Session.self).first {
           realm.beginWrite()
           session.foodtrucks.removeAll()
           session.foodtrucks = List<Foodtruck>()
           realm.add(session, update: .modified)
           try! realm.commitWrite()
       }
    }
    
    static func removeRealmFoodtruckObject() {
        let realm = try! Realm()
        let item = realm.objects(Foodtruck.self)
        realm.beginWrite()
        realm.delete(item)
        try! realm.commitWrite()
    }
    
    //-> Create a new Session with a User
    static func createSession(user: User?) {
        
        if let u = user {
            let session = Session()
            session.sessionId = 1
            session.user = u
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(session)
            try! realm.commitWrite()
            LocalData.setValue(key: "connected_id", value: u.uid)
        }
       
    }
    
    //-> LOGOUT
    static func doLogout() {
        
        let realm = try! Realm()
        realm.beginWrite()
        realm.deleteAll()
        try! realm.commitWrite()
        
    }
    
    struct Local {
        static func isLogged() -> Bool {
            if let connected_id = LocalData.getValue(key: "connected_id", defaultValue: 0), connected_id > 0 {
                return true
            }
            return false
        }
    }
    
}
