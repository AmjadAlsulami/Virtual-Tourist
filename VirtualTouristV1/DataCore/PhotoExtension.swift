//
//  PhotoExtenshen.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 30/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//


import Foundation
import CoreData

extension Photo {
    public override func awakeFromInsert() {
        //set the createdDate propertie in creation
        super.awakeFromInsert()
        createdDate = Date()
    }
}
