//
//  Constants.swift
//  Virtual-Tourist
//
//  Created by Anindya Sengupta on 5/4/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import Foundation

enum MethodType: String {
    case delete = "DELETE"
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

struct URLs {
    static let flickrBaseURL = "https://api.flickr.com/services/rest/?&"
}

struct Endpoints {
    static let flickrURLPath = "/services/rest/"
}

struct Keys {
    static let kRegionKey = "kRegionKey"
}

var documentsDirectory : String {
    let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentDirectoryPath:String = path[0]
    return documentDirectoryPath
}
