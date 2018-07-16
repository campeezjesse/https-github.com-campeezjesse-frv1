//
//  CatchInfoViewController.swift
//  FishRuler
//
//  Created by user1 on 7/11/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class CatchInfoViewController: UIViewController {
    
    var fish: Fish!
    var storedLocations: [Fish]! = []
  
    
    var kindOfFish: String = ""
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var fishPic: UIImageView!
    @IBOutlet weak var fishLabel: UITextField!
    @IBOutlet weak var fishLength: UITextField!
    @IBOutlet weak var dateCought: UITextField!
    @IBOutlet weak var weterTemp: UITextField!
    @IBOutlet weak var baitCaughtOn: UITextField!
    @IBOutlet weak var theWeather: UITextField!
    @IBOutlet weak var otherInfo: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

       fishLabel.text = kindOfFish

//            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Fish")
//            //request.predicate = NSPredicate(format: "age = %@", "12")
//            request.returnsObjectsAsFaults = false
//            do {
//                let result = try context.fetch(request)
//                for data in result as! [NSManagedObject] {
//
//
//                    print("")
//                }
//
//            } catch {
//
//                print("Failed")
//            }

//        func getData() -> [Fish]? {
//
//
//
//
//            do {
//                storedLocations = try context.fetch(Fish.fetchRequest())
//                var annotations = [MKAnnotation]()
//                for storedLocation in storedLocations {
//                    let newAnnotation = MKPointAnnotation()
//                    newAnnotation.coordinate.latitude = storedLocation.latitude
//                    newAnnotation.coordinate.longitude = storedLocation.longitude
//                    newAnnotation.title = storedLocation.species
//                    newAnnotation.subtitle = storedLocation.length
//
//                    print("anything")
//
//                    annotations.append(newAnnotation)
//
//
//
//                }
//                print("fuuuuuuk")
//            }
//            catch {
//                print("Fetching Failed")
//            }
//            return nil
//        }

   }
}
