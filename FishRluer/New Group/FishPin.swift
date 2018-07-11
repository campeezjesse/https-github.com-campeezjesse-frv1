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
public class FishPin: NSManagedObject {
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitutde)
    }
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Fish", in: context) {
            self.init(entity: ent, insertInto: context)
            self.latitude = latitude
            self.longitutde = longitude
            
        } else {
            fatalError("Unable To Find Entity Name!")
        }
        
    }
}
extension Fish {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<FishPin>(entityName: "Fish")
    }
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitutde: Double
    
}
