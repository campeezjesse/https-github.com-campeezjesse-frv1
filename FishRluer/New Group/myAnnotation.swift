//
//  myAnnotation.swift
//  FishRuler
//
//  Created by user1 on 7/12/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import MapKit

class MyAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var newLength: String?
    var newTime: String?
    var newBait: String?
    var newNotes: String?
    var newWaterTempDepth: String?
    var newWeatherCond: String?
    var detailCalloutAccessoryView: UIStackView?
   
    
    
    init(coordinate: CLLocationCoordinate2D){
        self.coordinate = coordinate
    }

   
}