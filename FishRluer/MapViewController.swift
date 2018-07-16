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
    
   
    var myLength: String = ""
    var myTime = ""
    
    
    var fish: Fish!
    var storedLocations: [Fish]! = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
   
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
   
    
    @IBOutlet weak var map: MKMapView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.zoomToUserLocation()
        
        //Mark: - Authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        
        map.mapType = MKMapType.standard
        map.showsUserLocation = true
        
        if let annotations = getData() {
            map.addAnnotations(annotations)
        }
   
        
    }
    
    func getData() -> [MKAnnotation]? {
        
       
        
        
        
        do {
            storedLocations = try context.fetch(Fish.fetchRequest())
            var annotations = [MKAnnotation]()
            for storedLocation in storedLocations {
                let newAnnotation = MyAnnotation(coordinate: CLLocationCoordinate2D(latitude: storedLocation.latitude, longitude: storedLocation.longitude))
                newAnnotation.coordinate.latitude = storedLocation.latitude
                newAnnotation.coordinate.longitude = storedLocation.longitude
                newAnnotation.title = storedLocation.species
                newAnnotation.subtitle = storedLocation.length
                newAnnotation.newTime = storedLocation.time
                newAnnotation.newBait = storedLocation.bait
                newAnnotation.newNotes = storedLocation.notes
                newAnnotation.newWaterTempDepth = storedLocation.water
                newAnnotation.newWeatherCond = storedLocation.weather
                
                
                
                
              // print(storedLocation.length)
                let newLength = storedLocation.length
                let newTime = newAnnotation.newTime
//                let newBait = storedLocation.bait
//                let newNotes = storedLocation.notes
//                let newWaterTempDepth = storedLocation.water
//                let newWeatherCond = weatherCond

                myLength = newLength!
                myTime = newTime!
                
//
             
                annotations.append(newAnnotation)
                
             
                
            }
            
            return annotations
        }
        catch {
            print("Fetching Failed")
        }
        return nil
    }
    
 

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
           
            annotationView?.loadCustomLines(customLines: [myLength, myTime])
          
           
        } else {
            annotationView?.annotation = annotation
        }

        
        annotationView?.image = UIImage(named: "fish")


         return annotationView
       

        }
   
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
        
    }
    
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
extension MKAnnotationView {
    
    func loadCustomLines(customLines: [String]) {
        let stackView = self.stackView()
        for line in customLines {
            let label = UILabel()
            label.text = line
            stackView.addArrangedSubview(label)
        }
        self.detailCalloutAccessoryView = stackView
    }
    
    
    
    private func stackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        return stackView
    }
}




