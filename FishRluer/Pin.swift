//
//  Pin.swift
//  FishRuler
//
//  Created by user1 on 7/10/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import Foundation
import CoreData
import MapKit

//Pin Class
public class Pin: NSManagedObject {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitutde)
    }
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitutde = longitude
            
        } else {
            fatalError("Unable To Find Entity Name!")
        }
        
    }
}
