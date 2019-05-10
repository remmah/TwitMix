//
//  PreferenceManager.swift
//  TwitMix
//
//  Created by remmah on 4/1/16.

//

import Foundation

private let showBadgeIconKey = "showBadgeIcon"
private let badgeNumberKey = "badgeNumber"

class PreferenceManager {
    
    private let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var showBadgeIcon: Bool? {
        set (newBool) {
            userDefaults.setObject(newBool, forKey: showBadgeIconKey)
        }
        get {
            return userDefaults.objectForKey(showBadgeIconKey) as? Bool
        }
    }
    
    var badgeNumber: Int? {
        set (newInt) {
            userDefaults.setObject(newInt, forKey: badgeNumberKey)
        }
        get {
            return userDefaults.objectForKey(badgeNumberKey) as? Int
        }
    }
    
    init() {
        
        registerDefaultPreferences()
    }
    
    func registerDefaultPreferences() {
        
        let defaults = [ showBadgeIconKey : false ,
                         badgeNumberKey : 0 ]
        userDefaults.registerDefaults(defaults)
    }
}
