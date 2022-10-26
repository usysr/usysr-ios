//
//  LocalData.swift
//  Food Truck Finder
//
//  Created by Chazz Romeo on 12/15/19.
//  Copyright © 2020 Foodtruck Finder. All rights reserved.


import UIKit

class LocalData {
    
    
    static func setValue(key: String, value: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    
    static func setValue(key: String, value: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    static func setValue(key: String, value: Double) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    static func setValue(key: String, value: Int) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    static func setValue(key: String, value: Float) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
    }
    
    static func getValue(key: String, defaultValue: String) -> String {
        
        let defaults = UserDefaults.standard
        if let value = defaults.string(forKey: key) {
            return value
        }
        return defaultValue
        
    }
    
    static func getValue(key: String, defaultValue: Bool) -> Bool? {
        
        let defaults = UserDefaults.standard
        
        return defaults.bool(forKey: key)
    }
    
    static func getValue(key: String) -> Bool? {
        
        let defaults = UserDefaults.standard
        
        return defaults.bool(forKey: key)
    }
    
    static func getValue(key: String, defaultValue: Int) -> Int? {
        
        let defaults = UserDefaults.standard
        
        return defaults.integer(forKey: key)
    }
    
    static func getValue(key: String, defaultValue: Double) -> Double? {
        
        let defaults = UserDefaults.standard
        
        return defaults.double(forKey: key)
    }
    
    static func getValue(key: String, defaultValue: Float) -> Float? {
        
        let defaults = UserDefaults.standard
        
        return defaults.float(forKey: key)
        
    }
    
}
