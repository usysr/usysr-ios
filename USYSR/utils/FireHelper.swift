//
//  FireHelper.swift
//  Food Truck Finder
//
//  Created by Charles Romeo on 1/7/20.
//  Copyright © 2020 FoodTruck Finder. All rights reserved.
//

import Foundation
import FirebaseDatabase


class FireHelper{
    
    static let spotMonthDB = "MMMyyyy"
    static let DATE_MONTH = "MMMM"
    
    static let AVAILABLE: String = "available"
    static let PENDING: String = "pending"
    static let BOOKED: String = "booked"
    static let WAITING: String = "waiting"
    
    static let paymentIntentUrl = "https://us-central1-food-truck-finder-91dc0.cloudfunctions.net/charge/"
    static let FIRE_DATE_FORMAT = "EEE, MMM d yyyy, hh:mm:ss a"
    static var ref : DatabaseReference!
    //ADMIN
    static let ADMIN: String = "admin"
    static let FOODTRUCK_MANAGER: String = "foodtruck_manager"
    static let LOCATION_MANAGER: String = "location_manager"
    static let PROFILES: String = "Profiles"
    static let USERS: String = "users"
    static let LOCATIONS: String = "locations"
    static let FOODTRUCKS: String = "foodtrucks"
    //City
    static let AREAS: String = "areas"
    static let ALABAMA: String = "alabama"
    static let BIRMINGHAM: String = "birmingham"
    static var MONTH: String?
    static let SPOTS: String = "spots"
    
    //GET PROFILES
    static func getProfiles(key: String) -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.PROFILES)
    }
    
    //GET All Users
    static func getUsers() -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.PROFILES)
            .child(FireHelper.USERS)
    }
    //GET USER FOR KEY
    static func getUserForKey(key: String) -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.PROFILES)
            .child(key)
    }

    //GET Locations
    static func getLocationForUser(key: String) -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.PROFILES)
            .child("locations")
            .child(key)
    }
    
    //GET FoodTrucks
    static func getFoodtrucksForUser(key: String) -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.PROFILES)
            .child("foodtrucks")
            .child(key)
    }
    
    //GET Spots
    static func getSpotsForNextTwoMonths() -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.AREAS)
            .child(FireHelper.ALABAMA)
            .child(FireHelper.BIRMINGHAM)
            .child(FireHelper.SPOTS)
    }
    
    //GET Spots
    static func getSpots() -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.AREAS)
            .child(FireHelper.ALABAMA)
            .child(FireHelper.BIRMINGHAM)
            .child(FireHelper.SPOTS)
            .child(getSpotMonthYearForDB())
    }
    
    static func getSpotsForMonth(month: String) -> DatabaseReference {
        return Database.database()
            .reference(withPath: FireHelper.AREAS)
            .child(FireHelper.ALABAMA)
            .child(FireHelper.BIRMINGHAM)
            .child(FireHelper.SPOTS)
            .child(month)
    }
    
    //GET: -> CURRENT MONTHYEAR FOR FIREBASE DB
    static func getSpotMonthYearForDB() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = spotMonthDB
        return formatter.string(from: date)
    }
    
    //GET: -> CURRENT MONTHYEAR FOR FIREBASE DB
    static func getSpotMonthYearForDBbyDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = spotMonthDB
        return formatter.string(from: date)
    }
    
}

