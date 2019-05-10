//
//  APIClient.swift
//  TwitMix
//
//  Created by remmah on 3/28/16.

//

import UIKit
import CoreData

class APIClient: NSObject {

    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return formatter
    }()
    
    let dateDisplayFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return formatter
    }()
    
    // MARK: - Properties
    // Constants
    struct Constants {
        static let TwitAppID: String = {
            let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")
            let keyDict = NSDictionary(contentsOfFile: path!)
            return keyDict!["app-id"] as! String
        }()
        static let TwitAPIKey: String = {
            let path = NSBundle.mainBundle().pathForResource("Keys", ofType: "plist")
            let keyDict = NSDictionary(contentsOfFile: path!)
            return keyDict!["app-key"] as! String
        }()
        static let BaseURL: String = "https://twit.tv/api/v1.0/"
        static let ShowMethod = "shows"
        static let EpisodeMethod = "episodes?"
    }
    
    struct ParameterKeys {
        static let ShowFilter = "filter[shows]"
    }
    
    struct JSONKeys {
        static let Shows = "shows"
        static let ShowTitle = "label"
        static let ShowID = "id"
        static let CoverArt = "coverArt"
        static let CoverArtDerivs = "derivatives"
        static let Thumbnail = "thumbnail"
        static let Episodes = "episodes"
        static let EpisodeTitle = "label"
        static let EpisodeDate = "airingDate"
        static let EpisodeNumber = "episodeNumber"
        static let audioDict = "video_audio"
        static let AudioURL = "mediaUrl"
    }
    
    
    var session: NSURLSession
    var httpResponseCode: Int
    var downloadErrorCode: Int
    var errorString: String
    var errorSubString: String
    
    override init() {
        session = NSURLSession.sharedSession()
        httpResponseCode = 1
        downloadErrorCode = 1
        errorString = ""
        errorSubString = ""
    }
    
    // MARK: - JSON downloading and parsing
    
    func taskForGETMethod(method: String, parameters: [String:AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Build URL
        let urlString: String
        if let params = parameters {
            urlString = Constants.BaseURL + method + APIClient.escapedParameters(params)
        } else {
            urlString = Constants.BaseURL + method
        }
        print("\(urlString)")
        let url = NSURL(string: urlString)!
        
        // Configure and make request
        let request = NSMutableURLRequest(URL: url)
        request.addValue(Constants.TwitAppID, forHTTPHeaderField: "app-id")
        request.addValue(Constants.TwitAPIKey, forHTTPHeaderField: "app-key")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let _ = downloadError {
                print("Error downloading JSON")
                completionHandler(result: nil, error: downloadError)
            } else {
                print("JSON downloaded: Sending to parser")
                self.parseJSON(data!, completionHandler: completionHandler)
            }
        }
        
        // Start the request
        task.resume()
        return task
    }
    
    func parseJSON(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            print("\(error)")
            parsedResult = nil
        }
        
        if let error = parsingError {
            print("Error parsing JSON")
            completionHandler(result: nil, error: error)
        } else {
            print("Completed JSON parsing")
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    // MARK: - GET-related methods
    
    func getShowList(completionHandler: (result: [Show]) -> Void) {
        
        var showList = [Show]()
        
        taskForGETMethod(Constants.ShowMethod, parameters: nil) { JSONResult, error in
            if let _ = error {
                print("Returning empty Show array")
            } else {
                // Extract the top-level 'shows' object as an array of dictionaries containing the shows
                if let showsArray = JSONResult.valueForKey(JSONKeys.Shows) as? [[String : AnyObject]] {
                    // Extract the data for each show
                    for show in showsArray {
                        let showTitle = show[JSONKeys.ShowTitle] as! String
                        let showID = show[JSONKeys.ShowID] as! Int
                        let coverArtDict = show[JSONKeys.CoverArt] as! [String : AnyObject]
                        let coverArtDerivs = coverArtDict[JSONKeys.CoverArtDerivs] as! [String : AnyObject]
                        let coverArtString = coverArtDerivs[JSONKeys.Thumbnail] as! String
                        let coverArtURL = NSURL(string: coverArtString)!
                        var showDict = [String : AnyObject]()
                        showDict[Show.Keys.ShowName] = showTitle
                        showDict[Show.Keys.ShowID] = showID
                        showDict[Show.Keys.RemoteCoverArtURL] = coverArtURL
                        let aShow = Show(dictionary: showDict)
                        showList.append(aShow)
                    }
                } else {
                    print("Error extracting top-level 'shows' object. Returning empty array")
                }
            }
            completionHandler(result: showList)
        }
    }
    
    func getEpisodesForShow(show: Show, completionHandler: (result: [Episode]) -> Void) {
        
        var episodeList = [Episode]()
        
        var parameters = [String : AnyObject]()
        parameters[ParameterKeys.ShowFilter] = show.showID
        
        taskForGETMethod(Constants.EpisodeMethod, parameters: parameters) { JSONResult, error in
            if let _ = error {
                print("Returning empty Episodes array")
            } else {
                //print(JSONResult)
                // Extract the top-level 'episodes' object as an array of dictionaries containing the episodes
                if let episodesArray = JSONResult.valueForKey(JSONKeys.Episodes) as? [[String : AnyObject]] {
                    // Extract the data for each episode
                    for episode in episodesArray {
                        let number = episode[JSONKeys.EpisodeNumber] as! String
                        let title = episode[JSONKeys.EpisodeTitle] as! String
                        let dateString = episode[JSONKeys.EpisodeDate] as! String
                        let date = self.dateFormatter.dateFromString(dateString)
                        let urlDict = episode[JSONKeys.audioDict] as! [String : AnyObject]
                        let urlString = urlDict[JSONKeys.AudioURL] as! String
                        let url = NSURL(string: urlString)!
                        var episodeDict = [String : AnyObject]()
                        episodeDict[Episode.Keys.CoverArtFilename] = show.localCoverArtFilename
                        episodeDict[Episode.Keys.EpisodeNumber] = number
                        episodeDict[Episode.Keys.EpisodeTitle] = title
                        episodeDict[Episode.Keys.EpisodeDate] = date
                        episodeDict[Episode.Keys.AudioURL] = url
                        let anEpisode = Episode(dictionary: episodeDict)
                        episodeList.append(anEpisode)
                    }
                } else {
                    print("Error extracting top-level 'episodes' object. Returning empty array")
                }
            }
            completionHandler(result: episodeList)
        }
    }
    
    
    // MARK: - Class methods
    
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    class func escapedParameters(parameters: [String:AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // Make sure it is a string value
            let stringValue = "\(value)"
            print("\(stringValue)")
            
            // Escape it
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            // Append it
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return /*(!urlVars.isEmpty ? "?" : "") + */ urlVars.joinWithSeparator("&")
    }
    
    class func sharedInstance() -> APIClient {
        
        struct Singleton {
            static var sharedInstance = APIClient()
        }
        
        return Singleton.sharedInstance
    }
}
