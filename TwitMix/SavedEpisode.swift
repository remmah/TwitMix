//
//  SavedEpisode.swift
//  TwitMix
//
//  Created by remmah on 3/28/16.

//

import UIKit
import CoreData

class SavedEpisode: NSManagedObject {
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    @NSManaged var coverArtFilename: String
    @NSManaged var episodeNumber: String
    @NSManaged var title: String
    @NSManaged var date: NSDate
    @NSManaged var audioURL: String
    @NSManaged var playbackPosition: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(episode: Episode, context: NSManagedObjectContext) {
        
        // Core Data
        let entity = NSEntityDescription.entityForName("SavedEpisode", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        // Set vars from episode object provided
        coverArtFilename = episode.coverArtFilename
        episodeNumber = episode.episodeNumber
        title = episode.title
        date = episode.date
        audioURL = episode.audioURL.absoluteString
        playbackPosition = NSNumber(double: 0.0)
        
    }
    
    class func getSavedEpisodes() -> [SavedEpisode] {
        
        let episodeFetch = NSFetchRequest(entityName: "SavedEpisode")
        do {
            let savedEpisodes = try CoreDataStackManager.sharedInstance().managedObjectContext.executeFetchRequest(episodeFetch) as! [SavedEpisode]
            return savedEpisodes
        } catch {
            fatalError("Failed to fetch saved Episodes: \(error)")
        }

    }

}
