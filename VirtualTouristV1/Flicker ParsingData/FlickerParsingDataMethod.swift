//
//  FlickerParsingDataMethod.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 26/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import Foundation

extension FlickerParsingData {
    
    // MARK: func randomPageNumber() -> String
    func randomPageNumber() -> String {
        //to get a different image set every time I used the reandom function
        //Iassum that my app will provide 10 different pages only so Here Ichoose Randomely between them
        let number = Int.random(in: 0 ... 10)
        return "\(number)"
    }
    
    // MARK: bbox(latitude: Double, longitude: Double) -> String
    func bbox(latitude: Double, longitude: Double) -> String {
        
        let miniLon = max(longitude - SearchBBoxValues.SearchBBoxHalfWidth, SearchBBoxValues.SearchLonRange.0)
        let miniLat = max(latitude  - SearchBBoxValues.SearchBBoxHalfHeight, SearchBBoxValues.SearchLatRange.0)
        let maxiLon = min(longitude + SearchBBoxValues.SearchBBoxHalfWidth, SearchBBoxValues.SearchLonRange.1)
        let maxiLat = min(latitude  + SearchBBoxValues.SearchBBoxHalfHeight, SearchBBoxValues.SearchLatRange.1)
        return "\(miniLon),\(miniLat),\(maxiLon),\(maxiLat)"
    }
    
    // MARK: getting Flickers Photos By Location
    // func gettingFlickersPhotosByLocation(latitude:Double , longitude: Double, completion: @escaping (_ success: Bool, _ ResponseType: [Any]?, _ errorString: String?) -> Void)
    func gettingFlickersPhotosByLocation(latitude:Double , longitude: Double, completion: @escaping (_ success: Bool, _ ResponseType: [Any]?, _ errorString: String?) -> Void){
        
        //set the boundingBox
        let boundingBox = self.bbox(latitude: latitude, longitude: longitude)
        
        //set the URL Parameters
        let urlParameters =  [
            FlickerParsingData.ParameterKeys.Method: FlickerParsingData.ParameterValues.SearchMethod,
            FlickerParsingData.ParameterKeys.APIKey: FlickerParsingData.ParameterValues.APIKey,
            FlickerParsingData.ParameterKeys.SafeSearch: FlickerParsingData.ParameterValues.UseSafeSearch,
            FlickerParsingData.ParameterKeys.Extras: FlickerParsingData.ParameterValues.MediumURL,
            FlickerParsingData.ParameterKeys.Format: FlickerParsingData.ParameterValues.ResponseFormat,
            FlickerParsingData.ParameterKeys.NoJSONCallback: FlickerParsingData.ParameterValues.DisableJSONCallback, FlickerParsingData.ParameterKeys.Accuracy: FlickerParsingData.ParameterValues.Accuracy, FlickerParsingData.ParameterKeys.BoundingBox: boundingBox ,FlickerParsingData.ParameterKeys.PhotoPage : randomPageNumber(), FlickerParsingData.ParameterKeys.PhotosPerPage:  FlickerParsingData.ParameterValues.PhotosPerPage] as [String : Any]
        
        // Creat the URL
        let url = FlickerParsingData.SharedPoint().creatURL( apiparameters: (urlParameters as! [String : String]))
        
        
        // start a get reques usig taskForGETRequest
        
        _ = taskForGETRequest( withURL: url , ResponseType: Response.self) { (result, error) in
            
            //check errors
            if let error = error {
                
                completion(false ,nil,"\(error.localizedDescription)")
            }else {
                //check result and return photos array
                let newresult = result as! Response
                if newresult.stat == "ok" {
                    let photoArray = newresult.photos.photo
                    if  photoArray.isEmpty == false {
                        
                        completion(true ,photoArray,nil)
                        
                    }else {
                        completion(false ,nil,"No Photos Found.")
                    }
                }
                else{
                    completion(false ,nil,"\( error!.localizedDescription)")
                }
                
            }
        }
    }
}



