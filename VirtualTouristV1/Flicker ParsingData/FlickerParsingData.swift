//
//  FlickerParsingData.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 26/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import Foundation
// MARK: class  FlickerParsingData :  NSObject
class  FlickerParsingData :  NSObject{
    
   // MARK: Properties
    // set shared session
    var session = URLSession.shared
    
    // set session Id
    var sessionID : String? = nil
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    
    // MARK: Methods
    
    //MARK: Utilizing Methods
    
    // func creatURL( apiparameters: [String:String]?) -> URL
    func creatURL( apiparameters: [String:String]?) -> URL {
        //create and set urL components
        var urLcomponents = URLComponents()
        urLcomponents.scheme = Constants.APIScheme
        urLcomponents.host = Constants.APIHost
        urLcomponents.path = Constants.APIPath
        urLcomponents.queryItems = [URLQueryItem]()
        
        if let parameters = apiparameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: value)
                urLcomponents.queryItems!.append(queryItem)
            }
        }
        //retrun the created url urLcomponents
        return urLcomponents.url!
    }
    
    // Make SharedPoint() Instance
    class func SharedPoint() -> FlickerParsingData {
        struct SharedPoint {
            static var sharedInstance = FlickerParsingData()
        }
        return SharedPoint.sharedInstance
    }
    
    // MARK: func  taskForGETRequest<ResponseType: Decodable>(withURL url: URL, ResponseType:ResponseType.Type, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask
    
    func  taskForGETRequest<ResponseType: Decodable>(withURL url: URL, ResponseType:ResponseType.Type, completion: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //defined the error " to getthe error message
        func defindError(_ error: String) {
            print(error)
            let message = [NSLocalizedDescriptionKey : error]
            completion(nil, NSError(domain: "taskForGETRequest", code: 1, userInfo: message))
        }
        
        // configure the url with the use of  NSMutableURLRequest to mutate the request object for a series of URL load requests
        let request = NSMutableURLRequest(url: url)
        
        //  lets start the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            
            //  GUARD: check errors
            guard (error == nil) else {
                defindError("\(error!.localizedDescription)")
                return
            }
            
            // GUARD:  check if the request was successful
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    switch statusCode {
                    case 404 : defindError("Not found")
                    default : defindError("Not successful request: \(statusCode)")
                    }
                    
                }
                defindError("Not successful request")
                return
            }
            
            // GUARD:  is there a succesful data returned from the request
            guard let data = data else {
                defindError("No data returned!")
                return
            }
            
            // parse the data
            do {
                let response = try JSONDecoder().decode(ResponseType, from: data)
                
                completion(response as ResponseType as AnyObject, nil)
                
            } catch {
                let message = [NSLocalizedDescriptionKey : "Could not parse the data: '\(data)'"]
                completion(nil, NSError(domain: "", code: 1, userInfo: message))
            }
        }
        
        
        task.resume()
        
        return task
        
    }
    
    
}
