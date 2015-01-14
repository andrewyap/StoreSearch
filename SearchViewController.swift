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
  var hasSearched = false
  
  
  // MARK: - Outlets
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
    

  // MARK: - Navigation

}


// MARK: - Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchResults = [SearchResult]()
    searchBar.resignFirstResponder()
    hasSearched = true
    if searchBar.text != "justin bieber" {
      for i in 0...2 {
        let searchResult = SearchResult()
        searchResult.name = String(format: "Fake Result %d for", i)
        searchResult.artistName = searchBar.text
        searchResults.append(searchResult)
      }
    }
    tableView.reloadData()
    println("The search text is: '\(searchBar.text)'")
  }
  
  func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
    return .TopAttached
  }
}

// MARK: - Table View - Data Source
extension SearchViewController: UITableViewDataSource {
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !hasSearched {
      return 0
    } else if searchResults.count == 0 {
      return 1
    } else {
      return searchResults.count
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cellIdentifier = "SearchResultCell"
    var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
    }
    
    if searchResults.count == 0 {
      cell.textLabel!.text = "Sorry, nothing was found :("
      cell.detailTextLabel!.text = ""
    } else {
      let searchResult = searchResults[indexPath.row]
      cell.textLabel!.text = searchResult.name
      cell.detailTextLabel!.text = searchResult.artistName
    }
    return cell
  }
}

// MARK: - Table View - Delegate

extension SearchViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
    if searchResults.count == 0 {
      return nil
    } else {
      return indexPath
    }
  }
}