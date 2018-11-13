//
//  CatchData.swift
//  FishRuler
//
//  Created by user1 on 11/13/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

class FishCaught {
//    var fullName: String?
//    var pictureUrl: String?
//    var email: String?
//    var about: String?
//    var friends = [Friend]()
//    var profileAttributes = [Attribute]()
    
    
    
    var fishLength: String?
    var baitUsed: String?
    var waterCond: String?
    var notesTaken: String?
    var timeOf: String?
    var windSpeed: String?
    var temp: String?
    var weatherSum: String?
    var ID: String?
    
    var fish = [NSManagedObject]()
    
    init?(data: Data) {

        do{
            let request: NSFetchRequest<Fish> = Fish.fetchRequest()
 
            let catchLocations = try context.fetch(request)
            for catchLocation in catchLocations{
                fishLength = catchLocation.length
                baitUsed = catchLocation.bait
                waterCond = catchLocation.water
                notesTaken = catchLocation.notes
                timeOf = catchLocation.time
                windSpeed = catchLocation.windSpeed
                temp = catchLocation.currentTemp
                weatherSum = catchLocation.weatherSummary
                ID = catchLocation.annoID
                
                
                fish.append(catchLocation)
               
            }
            
        } catch {
            print("Failed")
        }
        
}
}

class Trips{
    var date: String?
    var numOfFish: Double?
    var tripID: String?
    
    
    var trips = [NSManagedObject]()
    
    init?(data: Data) {
    
    do{
    let request: NSFetchRequest<Routes> = Routes.fetchRequest()
    
    let tripLocations = try context.fetch(request)
    for tripLocation in tripLocations{
        
        date = tripLocation.date
        numOfFish = tripLocation.bites
        tripID = tripLocation.catchID
    
    
    trips.append(tripLocation)
    
    
    }
    
    } catch {
    print("Failed")
    }
    
}

//        do {
//            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["data"] as? [String: Any] {
//                self.fullName = body["fullName"] as? String
//                self.pictureUrl = body["pictureUrl"] as? String
//                self.about = body["about"] as? String
//                self.email = body["email"] as? String
//
//                if let friends = body["friends"] as? [[String: Any]] {
//                    self.friends = friends.map { Friend(json: $0) }
//                }
//
//                if let profileAttributes = body["profileAttributes"] as? [[String: Any]] {
//                    self.profileAttributes = profileAttributes.map { Attribute(json: $0) }
//                }
//            }
//        } catch {
//            print("Error deserializing JSON: \(error)")
//            return nil
//        }
//    }
//}
