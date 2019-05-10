//
//  BrowseController.swift
//  TwitMix
//
//  Created by remmah on 3/23/16.

//

import UIKit

class BrowseController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var shows = [Show]()
    var coverArtDownloadIsComplete = false
    var session: NSURLSession = NSURLSession.sharedSession()
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var failView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if coverArtDownloadIsComplete { return }
        
        tableView.hidden = true
        loadingView.hidden = false
        failView.hidden = true
        
        view.bringSubviewToFront(loadingView)
        getRemoteShows()
    }
    
    func getRemoteShows() { // Gets a list of shows from the TWiT API
        
        APIClient.sharedInstance().getShowList() {showList in
            self.shows = showList
            if showList.isEmpty {
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
            self.evaluateCoverArt()
        }
    }
    
    @IBAction func tryButtonTapped(sender: UIButton) {
        
        failView.hidden = true
        loadingView.hidden = false
        view.bringSubviewToFront(loadingView)
        getRemoteShows()
    }
    
    
    // MARK: - Cover Art Management
    func evaluateCoverArt() { // Determines which covers need to be downloaded, if any
        
        for show in shows {
            if show.localCoverArtIsAvailable == false {
                downloadRemoteCoverArtToCache(show)
            }
        }
    }
    
    func completeDownloadCheck() { // Checks if all covers have been downloaded
        
        var coversLeftToDownload = 0
        for show in shows {
            if show.localCoverArtIsAvailable == false {
                coversLeftToDownload = coversLeftToDownload + 1
            }
        }
        
        if coversLeftToDownload == 0 {
            coverArtDownloadIsComplete = true
        }
    }

    func downloadRemoteCoverArtToCache(show: Show) {
        
        let filename = show.remoteCoverArtURL.lastPathComponent!
        let task = session.dataTaskWithURL(show.remoteCoverArtURL) {data, response, downloadError in
            if let _ = downloadError {
                print("Error downloading cover art: \(show.remoteCoverArtURL)")
            } else {
                // Save to cache
                let localFileUrl = self.cacheURLForFileName(filename)
                data!.writeToFile(localFileUrl.path!, atomically: true)
                
                // Set the Show variables
                show.localCoverArtFilename = filename
                show.localCoverArtIsAvailable = true
                
                let index = self.shows.indexOf(show)
                let indexPath = NSIndexPath(forItem: index!, inSection: 0)
                let indexPathArray = [NSIndexPath](arrayLiteral: indexPath)
                dispatch_async(dispatch_get_main_queue(), { self.tableView.reloadRowsAtIndexPaths(indexPathArray, withRowAnimation: .Automatic) })
                self.completeDownloadCheck()
            }
        }
        task.resume()
    }
    
    func cacheURLForFileName(name: String) -> NSURL {
        
        var paths = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        let cacheURL = paths[0]
        return cacheURL.URLByAppendingPathComponent(name)
    }
    
    
    // MARK: UITableViewDelegate/DataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return shows.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Dequeue a cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ShowCell", forIndexPath: indexPath)
        
        // Set the cell's image to the coverArt or a placeholder depending on state
        let cellShow = shows[indexPath.row]
        if cellShow.localCoverArtIsAvailable {
            let coverArtURL = cacheURLForFileName(cellShow.localCoverArtFilename!)
            let data = NSData(contentsOfURL: coverArtURL)
            let image = UIImage(data: data!)
            cell.imageView!.image = image
        } else {
            cell.imageView!.image = UIImage(named: "placeholder")
        }
        
        // Set the cell's label to showTitle
        cell.textLabel?.text = cellShow.showName
        
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let browseEpisodesController = segue.destinationViewController as! BrowseEpisodesController
        let indexPath = tableView.indexPathForSelectedRow
        browseEpisodesController.selectedShow = shows[indexPath!.row]
    }
}
