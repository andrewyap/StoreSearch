//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by Andrew Yap on 14/01/2015.
//  Copyright (c) 2015 Nimblic. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

  // MARK: - Instance variables
  var searchResults = [SearchResult]()
  var hasSearched = false // var to know if user has ever performed a search
  var isLoading = false // var to know if app is retrieving data from Apple servers
  
  // MARK: - Constants
  struct TableViewCellIdentifiers {
    static let searchResultCell = "SearchResultCell"
    static let nothingFoundCell = "NothingFoundCell"
    static let loadingCell = "LoadingCell"
  }
  
  // MARK: - Outlets
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    tableView.rowHeight = 80
    searchBar.becomeFirstResponder()

    // Register the NIB files
    var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
    
    cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
    tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  
  // MARK: - Format Apple API Request
  func urlWithSearchText(searchText: String) -> NSURL {
    let escapedSearchText = searchText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
    let urlString = String(format: "http://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
    let url = NSURL(string: urlString)
    return url!
  }
  
  // MARK: - Perform Apple API Request (return as String)


  // MARK: - JSON Parser
  func parseJSON(data: NSData) -> [String: AnyObject]? {
    var error: NSError?
      if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error) as? [String: AnyObject] {
        return json
      } else if let error = error {
        println("JSON Error: '\(error)'")
      } else {
        println("Unknown JSON Error")
      }
    return nil
  }
  
  // MARK: - Parse Dictionary
  func parseDictionary(dictionary: [String: AnyObject]) -> [SearchResult]{
    var searchResults = [SearchResult]()
    
    if let array: AnyObject = dictionary["results"] {
      for resultDict in array as [AnyObject] {
        if let resultDict = resultDict as? [String: AnyObject] {
          var searchResult: SearchResult?
          
          if let wrapperType = resultDict["wrapperType"] as? NSString {
            switch wrapperType {
              case "track":
                searchResult = parseTrack(resultDict)
              case "audiobook":
                searchResult = parseAudioBook(resultDict)
              case "software":
                searchResult = parseSoftware(resultDict)
            default:
              break
            }
          } else if let kind = resultDict["kind"] as? NSString {
            if kind == "ebook" {
              searchResult = parseEBook(resultDict)
            }
          }
          
          if let result = searchResult {
            searchResults.append(result)
          }
        } else {
          println("Expected a dictionary")
        }
      }
    } else {
      println("Expected 'results' array")
    }
    return searchResults
  }
  
  // MARK: - Parse API return data
  func parseTrack(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeURL = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["trackPrice"] as? NSNumber {
      searchResult.price = Double(price)
    }
    
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    
    return searchResult
  }
  
  func parseAudioBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["collectionName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeURL = dictionary["collectionViewUrl"] as NSString
    searchResult.kind = "audiobook"
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["collectionPrice"] as? NSNumber {
      searchResult.price = Double(price)
    }
   
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    return searchResult
  }
  
  func parseSoftware(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkURL100"] as NSString
    searchResult.storeURL = dictionary["trackViewIUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["price"] as? NSNumber {
      searchResult.price = Double(price)
    }
    
    if let genre = dictionary["primaryGenreName"] as? NSString {
      searchResult.genre = genre
    }
    
    return searchResult
  }
  
  func parseEBook(dictionary: [String: AnyObject]) -> SearchResult {
    let searchResult = SearchResult()
    searchResult.name = dictionary["trackName"] as NSString
    searchResult.artistName = dictionary["artistName"] as NSString
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as NSString
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as NSString
    searchResult.storeURL = dictionary["trackViewUrl"] as NSString
    searchResult.kind = dictionary["kind"] as NSString
    searchResult.currency = dictionary["currency"] as NSString
    
    if let price = dictionary["price"] as? NSNumber {
      searchResult.price = Double(price)
    }
    
    if let genres: AnyObject = dictionary["genres"] {
      searchResult.genre = ", ".join(genres as [String])
    }
    
    return searchResult
  }
  
  
  // MARK: - Format API return data: Kind
  func kindForDisplay(kind: String) -> String {
    switch kind {
      case "album": return "Album"
      case "audiobook": return "Audio Book"
      case "book": return "Book"
      case "ebook": return "E-Book"
      case "feature-movie": return "Movie"
      case "music-video": return "MusicVideo"
      case "podcast": return "Podcast"
      case "software": return "App"
      case "song": return "Song"
      case "tv-episode": return "TV Episode"
      default: return kind
    }
  }
  
  // MARK: - API Request Error Handling
  func showNetworkError() {
    let alert = UIAlertController(
      title: "Whoops...",
      message: "There was an error reading from the iTunes Store. Please try again.",
      preferredStyle: .Alert
    )
    
    let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(action)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - Navigation

}


// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    if !searchBar.text.isEmpty {
      searchBar.resignFirstResponder()
      
      
      isLoading = true
      tableView.reloadData()
      
      hasSearched = true
      searchResults = [SearchResult]()
      
      let url = self.urlWithSearchText(searchBar.text)
      let session = NSURLSession.sharedSession()
      let dataTask = session.dataTaskWithURL(url, completionHandler: {
        data, response, error in
        
        println("On the main thread? " + (NSThread.currentThread().isMainThread ? "Yes" : "No"))
        
        if let error = error {
          println("Failure ! \(error)")
        } else if let httpResponse = response as? NSHTTPURLResponse {
          if httpResponse.statusCode == 200 {
            if let dictionary = self.parseJSON(data) {
              self.searchResults = self.parseDictionary(dictionary)
              self.searchResults.sort { $0.name.localizedStandardCompare($1.name) == NSComparisonResult.OrderedAscending }
              
              dispatch_async(dispatch_get_main_queue()) {
                self.isLoading = false
                self.tableView.reloadData()
              }
              return
            }
          } else {
            println("Failure! \(response)")
          }
        }
        dispatch_async(dispatch_get_main_queue()) {
          self.hasSearched = false
          self.isLoading = false
          self.tableView.reloadData()
          self.showNetworkError()
        }
      })
      
      dataTask.resume()
    }
  }
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

// MARK: - Table View - Data Source
extension SearchViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isLoading {
      return 1
    } else if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    if isLoading {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as UITableViewCell
      
      let spinner = cell.viewWithTag(100) as UIActivityIndicatorView
      spinner.startAnimating()

      return cell
    } else if searchResults.count == 0 {
      return tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as UITableViewCell
    } else {
      let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as SearchResultCell
      let searchResult = searchResults[indexPath.row]
      cell.nameLabel.text = searchResult.name
      if searchResult.artistName.isEmpty {
        cell.artistNameLabel.text = "Unknown"
      } else {
        cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artistName, kindForDisplay(searchResult.kind))
      }
      return cell
    }
  }
}

// MARK: - Table View - Delegate

extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 || isLoading {
      return nil
    } else {
      return indexPath
    }
  }
}