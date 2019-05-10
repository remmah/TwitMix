//
//  Episode.swift
//  TwitMix
//
//  Created by remmah on 3/28/16.

//

import UIKit

class Episode: NSObject {
    
    let coverArtFilename: String
    let episodeNumber: String
    let title: String
    let date: NSDate
    let audioURL: NSURL
    
    struct Keys {
        static let CoverArtFilename = "coverArtFilename"
        static let EpisodeNumber = "episodeNumber"
        static let EpisodeTitle = "episodeTitle"
        static let EpisodeDate = "episodeDate"
        static let AudioURL = "audioURL"
    }
    
    init(dictionary: [String : AnyObject]) {
        
        coverArtFilename = dictionary[Keys.CoverArtFilename] as! String
        episodeNumber = dictionary[Keys.EpisodeNumber] as! String
        title = dictionary[Keys.EpisodeTitle] as! String
        date = dictionary[Keys.EpisodeDate] as! NSDate
        audioURL = dictionary[Keys.AudioURL] as! NSURL
        super.init()
    }

}
