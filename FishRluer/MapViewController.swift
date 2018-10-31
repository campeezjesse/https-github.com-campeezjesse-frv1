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
   
    var catchSub: String = ""
    
 
    
    var myFishAnnotation: [MyAnnotation] = []
    var selectedAnnotation: MyAnnotation?
    
    
 
    
    var catchID: String = ""
    var fish: Fish!
    var storedLocations: [Fish]! = []
    var catches: [Fish]! = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
    
    // Drawing a line to follow
    let startPin = MKPointAnnotation()
    private var route: Routes?
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
   
    
    @IBOutlet weak var takePictureOfPath: UIButton!
    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var buttonToStart: UIButton!
    @IBOutlet weak var buttonToStop: UIButton!
    @IBOutlet weak var buttonToAddCatch: UIButton!
    
    @IBOutlet weak var addACatchButton: UIView!
    @IBOutlet weak var stopFollowingButton: UIView!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var startFollowButton: UIView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var trackingOutput: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    
    @IBOutlet weak var snapShotView: UIView!
    
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
        
        // Buttons
        startFollowButton.layer.borderWidth = 1
        startFollowButton.layer.cornerRadius = 5
        startFollowButton.layer.borderColor = UIColor.black.cgColor
        
        stopFollowingButton.layer.borderWidth = 1
        stopFollowingButton.layer.cornerRadius = 5
        stopFollowingButton.layer.borderColor = UIColor.black.cgColor
        stopFollowingButton.isHidden = true
        
        addACatchButton.layer.borderWidth = 1
        addACatchButton.layer.cornerRadius = 5
        addACatchButton.layer.borderColor = UIColor.black.cgColor
        
        
        addPullUpController()
        trackingOutput.isHidden = true
  
        
        //Mark: - Authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        
        
        map.mapType = MKMapType.satelliteFlyover
        map.showsUserLocation = true
        
        takePictureOfPath.isHidden = true
        
 
        
    }
    
    private func addPullUpController() {
        let pullUpController = makeSearchViewControllerIfNeeded()
        addPullUpController(pullUpController, animated: true)
       
        NSLayoutConstraint.activate([
            
            // Anchor Buttons to Pull Up
            buttonView.bottomAnchor.constraint(equalTo: pullUpController.searchBar.topAnchor),

            ])
    }
    
    
    func zoom(to location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    func addStartPin() {
        
        trackingOutput.isHidden = false
        

        
        let startFollowPin = CatchAnnotation()
        startFollowPin.title = "Start Showing"
        startFollowPin.subtitle = "Path"
        startFollowPin.pinImageName = "start"
        
        startFollowPin.coordinate = CLLocationCoordinate2D(latitude: map.userLocation.coordinate.latitude, longitude: map.userLocation.coordinate.longitude)
     
       
        map.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        map.removeOverlays(map.overlays)
        map.addAnnotation(startFollowPin)
        
        seconds = 0
        distance = Measurement(value: 0, unit: UnitLength.meters)
        locationList.removeAll()
        updateDisplay()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
            
        }
        startLocationUpdates()
    }
 
    func addStopPin() {
   
        
        let alertController = UIAlertController(title: "Stop Following?",
                                                message: "Are you done with this trip?",
                                                preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            
            self.startFollowButton.isHidden = true
            self.stopFollowingButton.isHidden = false
            
        
            })
        
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            
            self.saveRun()
            let stopFollowPin = CatchAnnotation()
            stopFollowPin.title = "Stop"
            stopFollowPin.subtitle = "Path"
            stopFollowPin.pinImageName = "stop"
            
            stopFollowPin.coordinate = CLLocationCoordinate2D(latitude: self.map.userLocation.coordinate.latitude, longitude: self.map.userLocation.coordinate.longitude)
            
            self.locationManager.stopUpdatingLocation()
            self.timer?.invalidate()
            
            self.map.addAnnotation(stopFollowPin)
            
            self.map.selectAnnotation(self.startPin, animated: true)
            //self.map.selectAnnotation(stopFollowPin, animated: true)
            
            self.takeSnapShot()
            
            self.takePictureOfPath.isHidden = false
            
            
            
        })
        alertController.addAction(UIAlertAction(title: "Delete Path", style: .destructive) { _ in
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alertController, animated: true)
        
        
    }
    
    func takeSnapShot() {
        
    let mapPic = snapShotView.screenshot()
        mapImageView.image = mapPic
        

        }
    


    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedDistance = FormatDisplay.distance(distance)
        let formattedTime = FormatDisplay.time(seconds)
        let formattedPace = FormatDisplay.pace(distance: distance,
                                               seconds: seconds,
                                               outputUnit: UnitSpeed.minutesPerMile)
        
        distanceLabel.text = "Distance:  \(formattedDistance)"
        timeLabel.text = "Time:  \(formattedTime)"
        paceLabel.text = "Pace:  \(formattedPace)"
    }
    
    private func startLocationUpdates() {
        locationManager.delegate = self
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        locationManager.startUpdatingLocation()
    }
    
    private func saveRun() {
        let newRoute = Routes(context: CoreDataStack.context)
        newRoute.distance = distance.value
        newRoute.duration = Int16(seconds)
        newRoute.timestamp = Date()
        
        for location in locationList {
            let locationObject = RouteLocation(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRoute.addToRouteLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        
        route = newRoute
    }
    
    func addCatchPins() {
        
       
                if let catchAnno = getData() {
                    map.addAnnotations(catchAnno)
                }
        }
    
    
    func removeCatchPins() {
        
        let filteredAnnotations = map.annotations.filter { annotation in
            if annotation is MKUserLocation { return false }          // don't remove MKUserLocation
            guard let subTitle = annotation.subtitle else { return false }  // don't remove annotations without any title
            
          
            return subTitle != "Path"                         // remove those whose title does not match
        }
        
        map.removeAnnotations(filteredAnnotations)
     
      
            
    
    }
    
    func addPinToPath() {
        
        let catchPathPin = CatchAnnotation()
        
        let catchLat = map.userLocation.coordinate.latitude
        let catchLon = map.userLocation.coordinate.longitude
       
        catchPathPin.coordinate = CLLocationCoordinate2D(latitude: catchLat, longitude: catchLon)
        catchPathPin.title = "Fish On"
        catchPathPin.subtitle = "Path"
        catchPathPin.pinImageName = "catch"
        
 
        map.addAnnotation(catchPathPin)
    }
    
    
        
    @IBAction func addPinPath(_ sender: Any) {
        addPinToPath()
    }
    

    @IBAction func picOfPath(_ sender: Any) {
        
        takeSnapShot()
        
        performSegue(withIdentifier: "mapPic", sender: self)
    }
    
    // Catch Annotations
    
    func getData() -> [MKAnnotation]? {
        
        do {
            storedLocations = try context.fetch(Fish.fetchRequest())
            
            // Need to exclude here
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
    


    @IBAction func startFollow(_ sender: Any) {
        addStartPin()
        startFollowButton.isHidden = true
        stopFollowingButton.isHidden = false
    }
    
    @IBAction func stopFollow(_ sender: Any) {
        addStopPin()
        
        startFollowButton.isHidden = false
        stopFollowingButton.isHidden = true
        
    }
    

    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {
            return nil
        }
            
            if !(annotation is CatchAnnotation) {
                
                
                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"")
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                annotationView.animatesDrop = true
                
                let btn = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = btn
                
                if (annotation.title! == "Start") {
                    annotationView.image = UIImage(named: "startPin")
                    btn.isHidden = true
                }
                else if (annotation.title! == "The End") {
                    annotationView.image = UIImage(named: "stopPin")
                    btn.isHidden = true
                }
                
                return annotationView

//                return nil
            }
        
            let reuseID = "pin"
            
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
            if anView == nil {
                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                anView!.canShowCallout = true
            }
            else {
                anView!.annotation = annotation
            }
        
            let cpa = annotation as! CatchAnnotation
            anView!.image = UIImage(named:cpa.pinImageName)
            
            return anView
        }
    

            // This was working code
//
//            return nil
//        }
//
//        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "") {
//            annotationView.annotation = annotation
//            return annotationView
//
//        } else {
//
//            let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier:"pin")
//            annotationView.isEnabled = true
//            annotationView.canShowCallout = true
//            annotationView.animatesDrop = true
//
//            let btn = UIButton(type: .detailDisclosure)
//            annotationView.rightCalloutAccessoryView = btn
//
//                                if (annotation.title! == "Start") {
//                                    annotationView.image = UIImage(named: "startPin")
//                                    btn.isHidden = true
//                                }
//                                else if (annotation.title! == "The End") {
//                                    annotationView.image = UIImage(named: "stopPin")
//                                    btn.isHidden = true
//                                }
//
//            return annotationView
//        }
//    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            performSegue(withIdentifier: "editInfo", sender: view)
        }
    }
    

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? MyAnnotation
        
      
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is CatchDetailsViewController{
            
            let vc = segue.destination as? CatchDetailsViewController
            
            let theID = selectedAnnotation?.newTime
            
            vc?.catchID = theID!

        }
        else if segue.destination is ImagePreviewViewController{
            
            let ImVC = segue.destination as? ImagePreviewViewController
            
            let mapImage = mapImageView.image
            
            ImVC?.image = mapImage
            
    
    }
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


// MARK: - Location Manager Delegate

extension MapViewController {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                distance = distance + Measurement(value: delta, unit: UnitLength.meters)
                let coordinates = [lastLocation.coordinate, newLocation.coordinate]
                map.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
                let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
                map.setRegion(region, animated: true)
            }
            
            locationList.append(newLocation)
        }
    }
}

// MARK: - Map View Delegate

extension MapViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MKPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = .black
        renderer.lineWidth = 3
        return renderer
    }
}

extension UIView {
    
    func screenshot() -> UIImage {
        return UIGraphicsImageRenderer(size: bounds.size).image { _ in
            drawHierarchy(in: CGRect(origin: .zero, size: bounds.size), afterScreenUpdates: true)
        }
    }
    
}
