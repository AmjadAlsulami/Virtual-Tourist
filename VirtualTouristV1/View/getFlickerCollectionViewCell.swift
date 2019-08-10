//
//  getFlickerCollectionViewCell.swift
//  VirtualTouristV1
//
//  Created by Amjad khalid  on 26/01/2019.
//  Copyright © 2019 Amjad khaled. All rights reserved.
//

import UIKit

//MARK: class getFlickerCollectionViewCell: UICollectionViewCell
class getFlickerCollectionViewCell: UICollectionViewCell{
    //MARK: Outlets
    @IBOutlet weak var flickerPhoto: UIImageView!
    @IBOutlet weak var photoIndicator: UIActivityIndicatorView!
    
    
    //MARK:func startPlaceHolderIndicator()
    func startPlaceHolderIndicator() {
        self.photoIndicator.isHidden = false
        self.photoIndicator.startAnimating()
    }
    
    //MARK: func stopPlaceHolderIndicator()
    func stopPlaceHolderIndicator() {
        self.photoIndicator.isHidden = true
        self.photoIndicator.stopAnimating()
    }
}




