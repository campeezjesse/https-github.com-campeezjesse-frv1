//
//  MyCatchAnnotation.swift
//  FishRuler
//
//  Created by user1 on 7/12/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import MapKit

class MyCatchAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    var title: String? = ""
    
    var sizeOfFish: String? = ""
    var dateCaught: Date!
    var image: UIImage!
    var weatherWhenCaught: String!
    var waterConditionsWhenCaught: String!
    var baitUsedToCatch: String!
    var moreInfoOnCatch: String!
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
