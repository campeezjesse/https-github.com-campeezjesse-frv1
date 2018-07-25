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
    
   
//    var myLength: String? = ""
//    var myTime: String? = ""
//    var myBait: String? = ""
//    var myWeather: String? = ""
//    var myWater: String? = ""
//    var myNotes: String? = ""
//
    var myFishAnnotation: [MyAnnotation] = []
    
    
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

        
//                let newLength: String?
//                let newCatchTime: String?
//                let newCatchBait: String?
//                let newCatchWater: String?
//                let newCatchWeather: String?
//                let newCatchNotes: String?
//
//                newLength = storedLocation.length
//                newCatchTime = storedLocation.time
//                newCatchBait = storedLocation.bait
//                newCatchWater = storedLocation.water
//                newCatchWeather = storedLocation.weather
//                newCatchNotes = storedLocation.notes
//
//
//                myLength = newLength
//                myTime = newCatchTime
//                myBait = newCatchBait
//                myWater = newCatchWater
//                myWeather = newCatchWeather
//                myNotes = newCatchNotes
//
//
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
            annotationView = FishAnnotationViewController(annotation: annotation, reuseIdentifier: reuseIdentifier)

        } else {
            annotationView?.annotation = annotation
        }

        
       // annotationView?.image = UIImage(named: "fish")

       // configureDetailView(annotationView: annotationView!)
        
        //annotationView?.addSubview(detailsView)
        
         return annotationView
    

        }
    
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        let alertController = KOAlertController("Remove This Catch and All info attatched", "This can not be undone")
//
//        alertController.addAction(KOAlertButton(.default, title:"Close")) {
//
//        }
    //    self.present(alertController, animated: false) {}
      //  let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
//        alert.addAction(UIAlertAction(title: "DELETE", style: .default, handler: {action in self.delete(MKAnnotation.self)}))
//        alert.addAction(cancelAction)
     //   self.present(alert, animated: true, completion: nil)
        
  //  }
//    func configureDetailView(annotationView: MKAnnotationView) {
//
//
//
//        let detailView = detailsView
//        let views = ["detailView": detailView]
//
//     // sizeLabel.text = self.length
//     //   speciesLabel.text = myTime
//
//
//        detailView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[detailView(300)]", options: [], metrics: nil, views: views))
//        detailView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[detailView(200)]", options: [], metrics: nil, views: views))
//
//
//        annotationView.detailCalloutAccessoryView = detailView
//    }

//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//
//
//    }
//
//    func stopRecording() {
//
//        RPScreenRecorder.shared().stopRecording { (previewController, error) in
//            if error == nil {
//
//                let alertController = UIAlertController(title: "Recording", message: "You can view your recording to edit and share, or delete to try again", preferredStyle: .alert)
//
//                let discardAction = UIAlertAction(title: "Delete", style: .default) { (action: UIAlertAction) in
//                    RPScreenRecorder.shared().discardRecording(handler: { () -> Void in
//                        // Executed once recording has successfully been discarded
//                    })
//                }
//
//                let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action) in
//                    previewController?.previewControllerDelegate = self as? RPPreviewViewControllerDelegate
//                    self.present(previewController!, animated: true, completion: nil)
//                })
//
//                alertController.addAction(discardAction)
//                alertController.addAction(viewAction)
//
//                self.present(alertController, animated: true, completion: nil)
//
//            } else {
//                print(error ?? "")
//            }
//        }
//
//   }

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
//extension MKAnnotationView {
//    
//    func loadCustomLines(customLines: [String]) {
//        let stackView = self.stackView()
//        for line in customLines {
//            let label = UILabel()
//            label.text = line
//            stackView.addArrangedSubview(label)
//        }
//        self.detailCalloutAccessoryView = stackView
//    }
//    
//  
//    
//    private func stackView() -> UIStackView {
//        let stackView = UIStackView()
//        stackView.axis = .vertical
//        stackView.distribution = .fillEqually
//        stackView.alignment = .fill
//        return stackView
//    }
//}

//extension Fish: MKAnnotation {
//    public var coordinate: CLLocationCoordinate2D {
//
//
//        let latDegrees = CLLocationDegrees(latitude)
//        let longDegrees = CLLocationDegrees(longitude)
//        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
//
//
//    }
//}



