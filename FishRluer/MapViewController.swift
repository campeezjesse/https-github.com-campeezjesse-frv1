//
//  MapViewController.swift
//  FishRuler
//
//  Created by user1 on 6/28/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import ReplayKit
import CoreData
import PullUpController




class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

 
    var catchTitle: String = ""
    var catchSubTitle: String = ""
    var catchSpecies: String = ""
    var fishKind: String = ""
    var length: String = ""
    var date = Date()
    var waterTempDepth: String = ""
    var bait: String = ""
    var weatherCond: String = ""
    var notes: String = ""
    var time: String = ""
    
   

    var myFishAnnotation: [MyAnnotation] = []
    var selectedAnnotation: MyAnnotation?
    
    
    var fish: Fish!
    var storedLocations: [Fish]! = []
    var catches: [Fish]! = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
   
    
    @IBOutlet weak var map: MKMapView!

    
    //for pullUp
    private func makeSearchViewControllerIfNeeded() -> SearchViewController {
        let currentPullUpController = children
            .filter({ $0 is SearchViewController })
            .first as? SearchViewController
        if let currentPullUpController = currentPullUpController {
            return currentPullUpController
        } else {
            return UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPullUpController()
      
        
       // let pullUpController = makeSearchViewControllerIfNeeded()
        
        map.zoomToUserLocation()
        
        //Mark: - Authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        map.mapType = MKMapType.satelliteFlyover
        map.showsUserLocation = true
        
        if let annotations = getData() {
            map.addAnnotations(annotations)
        }
   
        
    }
    
    private func addPullUpController() {
        let pullUpController = makeSearchViewControllerIfNeeded()
        addPullUpController(pullUpController, animated: true)
    }
    
    func zoom(to location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }

    func getData() -> [MKAnnotation]? {
        
       
        
        
        
        do {
            storedLocations = try context.fetch(Fish.fetchRequest())
            var annotations = [MKAnnotation]()
            for storedLocation in storedLocations {
                let newAnnotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: storedLocation.latitude, longitude: storedLocation.longitude), title: "", subtitle: "", newLength: "", newTime: "", newBait: "", newNotes: "", newWaterTempDepth: "", newWeatherCond: "")
                newAnnotation.coordinate.latitude = storedLocation.latitude
                newAnnotation.coordinate.longitude = storedLocation.longitude
                newAnnotation.title = storedLocation.species
                newAnnotation.subtitle = storedLocation.length
                newAnnotation.newTime = storedLocation.time
                newAnnotation.newBait = storedLocation.bait
                newAnnotation.newNotes = storedLocation.notes
                newAnnotation.newWaterTempDepth = storedLocation.water
                newAnnotation.newWeatherCond = storedLocation.weather
                

        

             
                annotations.append(newAnnotation)
                
             
                
            }
            
            return annotations
        }
        catch {
            print("Fetching Failed")
        }
        return nil
    }
    
    func  deletePin() {
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let context = appDelegate.persistentContainer.viewContext
//        let requestDel = NSFetchRequest<NSFetchRequestResult>(entityName: "Fish")
//
//        let thisCatch = selectedAnnotation?.title
//        requestDel.returnsObjectsAsFaults = false
//
//        let predicateDel = NSPredicate(format: "species == %d", thisCatch!)
//        requestDel.predicate = predicateDel
//
//
//        do {
//            let locations = try context.fetch(requestDel)
//            for location in locations{
//                context.delete(location as! NSManagedObject)
//
//                self.map.removeAnnotation(selectedAnnotation!)
//                print("pinDeleted")
//            }
//        } catch {
//            print("Failed")
//        }
//
//        do {
//            try context.save()
//        } catch {
//            print("Failed saving")
//        }
//    }

        self.map.removeAnnotation(selectedAnnotation!)
    }
    
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        let reuseIdentifier = "pin"
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        

        if annotationView == nil {
            annotationView = FishAnnotationViewController(annotation: annotation, reuseIdentifier: reuseIdentifier)

        } else {
            annotationView?.annotation = annotation
        }


         return annotationView
    

        }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? MyAnnotation
        
      //  performSegue(withIdentifier: "seeCatch", sender: Any?(PullUpController.self))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CatchDetailsViewController{
            
            let vc = segue.destination as? CatchDetailsViewController
            
            let theID = selectedAnnotation?.newTime
            
            vc?.catchID = theID!

        }
    }
    

    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    @IBAction func goBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
}
    extension MKMapView {
        func zoomToUserLocation() {
            self.zoomToUserLocation(latitudinalMeters: 1000, longitudinalMeters: 1000)
        }
        
        func zoomToUserLocation(latitudinalMeters:CLLocationDistance,longitudinalMeters:CLLocationDistance)
        {
            guard let coordinate = userLocation.location?.coordinate else { return }
            self.zoomToLocation(location: coordinate, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
        }
        
        func zoomToLocation(location : CLLocationCoordinate2D,latitudinalMeters:CLLocationDistance = 1000,longitudinalMeters:CLLocationDistance = 1000)
        {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: latitudinalMeters, longitudinalMeters: longitudinalMeters)
            setRegion(region, animated: true)
        }
        
}
extension MapViewController: ExampleCalloutViewDelegate {
    func mapView(_ mapView: MKMapView, didTapDetailsButton button: UIButton, for annotation: MKAnnotation) {
        
     performSegue(withIdentifier: "editInfo", sender: self)
        
        //below code will present an allert with options
        
//        let alert = UIAlertController(title: "Edit or Delete", message: "Any changes are permenate!", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        let deleteDataAction = UIAlertAction(title: "delete", style: .destructive, handler: { action in
//
//            let pinTitle = self.selectedAnnotation?.newTime
//
//                do{
//                    let request: NSFetchRequest<Fish> = Fish.fetchRequest()
//                    let predicate = NSPredicate(format: "time == %@", pinTitle!)
//                    request.predicate = predicate
//
//                    let locations = try self.context.fetch(request)
//                    for location in locations{
//                        self.context.delete(location)
//
//                        self.map.removeAnnotation(self.selectedAnnotation!)
//                        print("pinDeleted")
//                    }
//                } catch {
//                    print("Failed")
//            }
//
//            do {
//                try self.context.save()
//            } catch {
//                print("Failed saving")
//            }
//
//        })
//
//
//        alert.addAction(UIAlertAction(title: "Add more info and save on map ", style: .default, handler: {action in self.performSegue(withIdentifier: "editInfo", sender: self)}))
//
//
//        alert.addAction(cancelAction)
//        alert.addAction(deleteDataAction)
//
//        self.present(alert, animated: true, completion: nil)
    }
}

