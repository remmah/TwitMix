//
//  SettingsController.swift
//  TwitMix
//
//  Created by remmah on 4/1/16.

//

import UIKit

class SettingsController: UIViewController {

    @IBOutlet weak var badgeIconSwtch: UISwitch!
    let preferenceManager = PreferenceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prompt for user acceptance of badge icon
        // Thanks to http://stackoverflow.com/a/28011198/1467918
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Badge, categories: nil))

        // Load switch state from user defaults
        let defaultSwitchState = preferenceManager.showBadgeIcon!
        let defaultBadgeNumber = preferenceManager.badgeNumber!
        badgeIconSwtch.on = defaultSwitchState
        UIApplication.sharedApplication().applicationIconBadgeNumber = defaultBadgeNumber
    }
    
    @IBAction func badgeIconSwitchPressed(sender: UISwitch) {
        
        // Toggle, save to user defaults
        let state = badgeIconSwtch.on
        preferenceManager.showBadgeIcon = state
        
        if badgeIconSwtch.on {
            turnOnBadgeIcon()
        } else {
            turnOffBadgeIcon()
        }
    }
    
    func turnOffBadgeIcon() {
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        preferenceManager.badgeNumber = 0
    }
    
    func turnOnBadgeIcon() {
        
        // Set badge icon to number of episodes
        let savedEpisodes = SavedEpisode.getSavedEpisodes()
        let numberOfEpisodes = savedEpisodes.count
        UIApplication.sharedApplication().applicationIconBadgeNumber = numberOfEpisodes
        preferenceManager.badgeNumber = numberOfEpisodes
    }
}
