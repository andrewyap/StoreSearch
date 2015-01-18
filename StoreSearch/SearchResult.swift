//
//  SearchResult.swift
//  StoreSearch
//
//  Created by Andrew Yap on 14/01/2015.
//  Copyright (c) 2015 Nimblic. All rights reserved.
//

import Foundation

class SearchResult {
  var name = ""
  var artistName = ""
  var artworkURL60 = ""
  var artworkURL100 = ""
  var storeURL = ""
  var kind = ""
  var currency = ""
  var price = 0.0
  var genre = ""
  
  // MARK: - Format API return data: Kind
  func kindForDisplay() -> String {
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
  
}