//
//  FlickerParsingDataConstent.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 26/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import Foundation

extension FlickerParsingData {
    // MARK: Constants
    struct Constants {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
    }
    
    // MARK:  Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let BoundingBox = "bbox"
        static let PhotoPage = "page"
        static let PhotosPerPage = "per_page"
        static let Accuracy = "accuracy"
        
    }
    
    // MARK: Search BBoxValues
    struct SearchBBoxValues {
        static let SearchBBoxHalfWidth = 0.2
        static let SearchBBoxHalfHeight = 0.2
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
        
    }
    
    // MARK: Parameter Values
    struct  ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "Eenter your APIKey"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = "24"
        static let Accuracy = "11"
        
    }
}
// MARK: Response Keys
struct Response: Codable{
    
    let photos :Photos
    let stat :String
}
// MARK: Photos Keys
struct Photos: Codable{
    let perpage : Int
    let photo: [PhotoInfo]
}
// MARK: PhotoInfo Keys
struct PhotoInfo: Codable {
    let id : String
    let url_m: String
}





