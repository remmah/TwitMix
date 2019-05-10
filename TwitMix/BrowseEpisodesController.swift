//
//  BrowseEpisodesController.swift
//  TwitMix
//
//  Created by remmah on 3/29/16.

//

import UIKit
import CoreData

class BrowseEpisodesController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    var selectedShow: Show?
    var episodes = [Episode]()
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var failView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.hidden = true
        loadingView.hidden = false
        failView.hidden = true
        navigationItem.title = "Select Episode(s)"
        
        view.bringSubviewToFront(loadingView)
        getRemoteEpisodes()
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        print("BrowseEP is disappearing, attempting to save using context: \(sharedContext.description)")
        do {
            try self.sharedContext.save()
        } catch {
            print("Unable to save context after leaving BrowseEP")
        }
    }
    
    func getRemoteEpisodes() { // Gets a list of a show's episodes from the TWiT API
        
        APIClient.sharedInstance().getEpisodesForShow(selectedShow!) {episodeList in
            self.episodes = episodeList
            if episodeList.isEmpty {
                // Display failView
                dispatch_async(dispatch_get_main_queue(), { self.loadingView.hidden = true })
                dispatch_async(dispatch_get_main_queue(), { self.failView.hidden = false })
                dispatch_async(dispatch_get_main_queue(), { self.view.bringSubviewToFront(self.failView) })
                return
            }
            dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadData() })
            dispatch_async(dispatch_get_main_queue(), { self.tableView.hidden = false })
            dispatch_async(dispatch_get_main_queue(), { self.loadingView.hidden = true })
            dispatch_async(dispatch_get_main_queue(), { self.view.bringSubviewToFront(self.tableView)})
            dispatch_async(dispatch_get_main_queue(), { self.checkForExistingSelections() })
        }
    }
    
    func checkForExistingSelections() { // Checks if the episode list has any saved episodes, and selects them
        
        print("checking for existing selections")
        // If any titles match, tell tableview to select it, hopefully without calling the didselect method
        let savedEpisodes = SavedEpisode.getSavedEpisodes()
        for savedEpisode in savedEpisodes {
            for localEpisode in episodes {
                if localEpisode.title == savedEpisode.title {
                    print("Found a match: \(localEpisode.title)")
                    let index = episodes.indexOf(localEpisode)
                    let indexPath = NSIndexPath(forRow: index!, inSection: 0)
                    let cell = tableView.cellForRowAtIndexPath(indexPath)
                    cell!.selected = true
                    print("\(localEpisode.title) should now be selected")
                }
            }
        }
    }

    @IBAction func tryButtonTapped(sender: UIButton) {
        
        failView.hidden = true
        loadingView.hidden = false
        view.bringSubviewToFront(loadingView)
        getRemoteEpisodes()
    }
    
    
    // MARK: - UITableViewDelegate/DataSource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return episodes.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Dequeue a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("episodeCell", forIndexPath: indexPath)

        // Configure the cell
        let cellEpisode = episodes[indexPath.row]
        cell.textLabel?.text = "Episode \(cellEpisode.episodeNumber): \(cellEpisode.title)"
        cell.detailTextLabel?.text = APIClient.sharedInstance().dateDisplayFormatter.stringFromDate(cellEpisode.date)

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        let episode = episodes[indexPath.row]
        print("\(episode.title) tapped")
        SavedEpisode(episode: episode, context: sharedContext)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let episode = episodes[indexPath.row]
        deleteSavedEpisodeWithTitle(episode.title)
    }
    
    func deleteSavedEpisodeWithTitle(title: String) {
        
        let savedEpisodes = SavedEpisode.getSavedEpisodes()
        for episode in savedEpisodes {
            if episode.title == title {
                sharedContext.deleteObject(episode)
            }
        }
    }
}
