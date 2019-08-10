//
//  PinExtension.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 30/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import Foundation
import MapKit
extension Pin {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //set the createdDate propertie in creation
        createdDate = Date()
    }
    
}

extension Pin :MKAnnotation {
    //get the pin's coordinate properties to use
    public var coordinate: CLLocationCoordinate2D {
        //Argument type 'Pin' does not conform to expected type 'MKAnnotation'
        let thelatitude = CLLocationDegrees(latitude)
        let thelongitude = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: thelatitude, longitude: thelongitude)
        
    }
    
}

