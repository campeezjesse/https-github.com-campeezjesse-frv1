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
import PullUpController
import CoreData


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
    
    var pointAnnotation: CatchAnnotation!
   // var pinAnnotationView: MKAnnotationView!
   
    var fish: Fish!
   
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    let locationManager = CLLocationManager()
    var storedLocations: [Fish]! = []
    
  
    
   
    
    @IBOutlet weak var map: MKMapView!

    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let annotations = getData() {
            map.addAnnotations(annotations)
        }
        
    
        addPullUpController()
    }
    
    func getData() -> [MKAnnotation]? {
        
        do {
            storedLocations = try context.fetch(Fish.fetchRequest())
            var annotations = [MKAnnotation]()
            for storedLocation in storedLocations {
                let newAnnotation = MKPointAnnotation()
                newAnnotation.coordinate.latitude = storedLocation.latitude
                newAnnotation.coordinate.longitude = storedLocation.longitude
                newAnnotation.title = storedLocation.species
                newAnnotation.subtitle = storedLocation.length
                
                annotations.append(newAnnotation)
            }
            return annotations
        }
        catch {
            print("Fetching Failed")
        }
        return nil
    }
    
        private func addPullUpController() {
            guard
                let pullUpController = UIStoryboard(name: "Main", bundle: nil)
                    .instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController
                else { return }
            
            addPullUpController(pullUpController)
        
        
        //Mark: - Authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        map.mapType = MKMapType.standard
        map.showsUserLocation = true
        
     
    }
//    private func configureView() {
//    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//
//
//        print("locations = \(locValue.latitude) \(locValue.longitude)")
//
//        if locations.count > 0 {
//
//            manager.stopUpdatingLocation()
//        }
//
//
//        let location = locations.last! as CLLocation
//        let catchLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//
//        let center = catchLocation
//        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
//        map.setRegion(region, animated: true)
//
//        pointAnnotation = CatchAnnotation()
//        pointAnnotation.pinImageName = "pin"
//        pointAnnotation.coordinate = catchLocation
//        pointAnnotation.title = catchSpecies + " " + catchTitle
//        pointAnnotation.subtitle = catchSubTitle
//
//
//        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
//
//
//        map.addAnnotation(pinAnnotationView.annotation!)
//
//
//    }
//
//
//
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }

        let reuseIdentifier = "pin"
        var annotationView = map.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }

        // let catchAnnotation = annotation as! CatchAnnotation
        annotationView?.image = UIImage(named: "pushPin")




            //map.zoomToUserLocation()

         return annotationView

        }
    func mapView(_ MapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == annotationView.rightCalloutAccessoryView {
            performSegue(withIdentifier: "showCatchDetails", sender: self)
            print("Going to the next VC!")
        }
    }


    //Add Saved Pin To Map
    
//    private func saveCatch() {
//        let newFish = Fish(context: CoreDataStack.context)
//        newFish.species = catchSpecies
//        newFish.date = date
//        newFish.length = length
//        newFish.bait = bait
//        newFish.water = waterTempDepth
//        newFish.weather = weatherCond
//
//
//        for location in locationList {
//            let locationObject = Location(context: CoreDataStack.context)
//
//            locationObject.latitude = location.coordinate.latitude
//            locationObject.longitude = location.coordinate.longitude
//            newFish.addToLocations(locationObject)
//        }
//
//        CoreDataStack.saveContext()
//
//        fish = newFish
//
//        loadMap()
//    }
    
//    private func mapRegion() -> MKCoordinateRegion? {
//        guard
//            let locations = fish?.locations,
//            locations.count > 0
//            else {
//                return nil
//        }
//
//        let latitudes = locations.map { location -> Double in
//            let location = location as! Location
//            return location.latitude
//        }
//
//        let longitudes = locations.map { location -> Double in
//            let location = location as! Location
//            return location.longitude
//        }
//        return mapRegion()
//    }
//
//        private func points() -> MKPointAnnotation {
//            guard let locations = fish?.locations else {
//                return MKPointAnnotation()
//            }
//
//            let coords: [CLLocationCoordinate2D] = locations.map { location in
//                let location = location as! Location
//                return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
//            }
//            return MKPointAnnotation()
//        }
//    private func loadMap() {
//        guard
//            let locations = fish?.locations,
//            locations.count > 0,
//            let region = mapRegion()
//            else {
//                let alert = UIAlertController(title: "Error",
//                                              message: "Sorry, this map has no catch locations saved",
//                                              preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
//                present(alert, animated: true)
//                return
//        }
//
//
//        map.addAnnotations([points()])
//
//    }
//

    
    func stopRecording() {
        
        RPScreenRecorder.shared().stopRecording { (previewController, error) in
            if error == nil {
                
                let alertController = UIAlertController(title: "Recording", message: "You can view your recording to edit and share, or delete to try again", preferredStyle: .alert)
                
                let discardAction = UIAlertAction(title: "Delete", style: .default) { (action: UIAlertAction) in
                    RPScreenRecorder.shared().discardRecording(handler: { () -> Void in
                        // Executed once recording has successfully been discarded
                    })
                }
                
                let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action) in
                    previewController?.previewControllerDelegate = self as? RPPreviewViewControllerDelegate
                    self.present(previewController!, animated: true, completion: nil)
                })
                
                alertController.addAction(discardAction)
                alertController.addAction(viewAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                print(error ?? "")
            }
        }
        
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
        
        func zoomToLocation(location : CLLocationCoordinate2D,latitudinalMeters:CLLocationDistance = 100,longitudinalMeters:CLLocationDistance = 100)
        {
            let region = MKCoordinateRegionMakeWithDistance(location, latitudinalMeters, longitudinalMeters)
            setRegion(region, animated: true)
        }
        
}





