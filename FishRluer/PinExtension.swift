//
//  PinExtension.swift
//  FishRuler
//
//  Created by user1 on 7/10/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import Foundation
import CoreData


extension Pin {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Fish")
    }
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitutde: Double
    
}
