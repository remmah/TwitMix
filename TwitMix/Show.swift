//
//  Show.swift
//  TwitMix
//
//  Created by remmah on 3/28/16.

//

import UIKit

class Show: NSObject {
    
    let showName: String
    let showID: Int
    let remoteCoverArtURL: NSURL
    var localCoverArtFilename: String? = nil
    var localCoverArtIsAvailable = false
    var episodeList = [Episode]()
    
    struct Keys {
        static let ShowName = "showName"
        static let ShowID = "showID"
        static let RemoteCoverArtURL = "remoteCoverArtURL"
        static let LocalCoverArtFilename = "localCoverArtFilename"
        static let EpisodeList = "episodeList"
    }
    
    init(dictionary: [String : AnyObject]) {
        
        showName = dictionary[Keys.ShowName] as! String
        showID = dictionary[Keys.ShowID] as! Int
        remoteCoverArtURL = dictionary[Keys.RemoteCoverArtURL] as! NSURL
        super.init()
    }

}
