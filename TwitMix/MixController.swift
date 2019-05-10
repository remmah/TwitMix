//
//  MixController.swift
//  TwitMix
//
//  Created by remmah on 3/23/16.

//

import UIKit
import CoreData
import AVFoundation
import AVKit

class MixController: UITableViewController {

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var savedEpisodes = [SavedEpisode]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fetch savedEpisodes from core data
        savedEpisodes = SavedEpisode.getSavedEpisodes()
        tableView.reloadData()
    }
    
    func cacheURLForFileName(name: String) -> NSURL {
        
        var paths = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let cacheURL = paths[0]
        return cacheURL.URLByAppendingPathComponent(name)
    }
    
    @IBAction func editButtonTapped(sender: UIBarButtonItem) {
        
        if tableView.editing {
            editButton.title = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            editButton.title = "Done"
            tableView.setEditing(true, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return savedEpisodes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Dequeue a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("SavedEpisodeCell", forIndexPath: indexPath)
        
        // Set CoverArt and labels
        let cellEpisode = savedEpisodes[indexPath.row]
        let coverArtURL = cacheURLForFileName(cellEpisode.coverArtFilename)
        let data = NSData(contentsOfURL: coverArtURL)
        let image = UIImage(data: data!)
        cell.imageView!.image = image
        cell.textLabel?.text = "\(cellEpisode.title)"
        cell.detailTextLabel?.text = APIClient.sharedInstance().dateDisplayFormatter.stringFromDate(cellEpisode.date)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if tableView.editing {
            return
        }
        
        // Set up and present the audio player
        let episode = savedEpisodes[indexPath.row]
        let urlString = episode.audioURL
        let url = NSURL(string: urlString)!
        print(url)
        let audioPlayer = AVPlayer(URL: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = audioPlayer
        
        /*
        let coverArtURL = cacheURLForFileName(episode.coverArtFilename)
        let data = NSData(contentsOfURL: coverArtURL)
        let image = UIImage(data: data!)
        let imageView = UIImageView(image: image!)
        playerViewController.contentOverlayView?.addSubview(imageView)
        */
 
        navigationController?.presentViewController(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        let episode = savedEpisodes[sourceIndexPath.row]
        savedEpisodes.removeAtIndex(sourceIndexPath.row)
        savedEpisodes.insert(episode, atIndex: destinationIndexPath.row)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            sharedContext.deleteObject(savedEpisodes[indexPath.row])
            savedEpisodes.removeAtIndex(indexPath.row)
            
            do {
                try sharedContext.save()
            } catch {
                print("Could not save after deleting saved episode")
            }
            
            var indexArray = [NSIndexPath]()
            indexArray.append(indexPath)
            tableView.deleteRowsAtIndexPaths(indexArray, withRowAnimation: .Automatic)
        }
    }
}
