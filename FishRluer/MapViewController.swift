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
 
    var selectedAnnotation: MyAnnotation?
    var pathAnnotations = [MKAnnotation]()
    var startFollowPin = CatchAnnotation()
    
    var catchID: String = ""
    var fish: Fish!
    var storedLocations: [Fish]! = []
    var catches: [Fish]! = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
 // Show routes on map
    var storedRoutes: [Routes]! = []

    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
    
    
    
    // Drawing a line to follow
    let startPin = MKPointAnnotation()
    private var route: Routes?
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
   

    

    @IBOutlet weak var saveButt: UIButton!
    @IBOutlet weak var dontSaveButt: UIButton!
    
    @IBOutlet weak var mapImageView: UIImageView!

    @IBOutlet weak var viewToSave: UIView!
    
    @IBOutlet weak var buttonToAddCatch: UIButton!
    @IBOutlet weak var addACatchButton: UIView!
    @IBOutlet weak var buttonView: UIView!
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
        saveButt.layer.borderWidth = 1
        saveButt.layer.cornerRadius = 5
        saveButt.layer.borderColor = UIColor.black.cgColor

        dontSaveButt.layer.borderWidth = 1
        dontSaveButt.layer.cornerRadius = 5
        dontSaveButt.layer.borderColor = UIColor.black.cgColor
       
        
        addACatchButton.layer.borderWidth = 1
        addACatchButton.layer.cornerRadius = 5
        addACatchButton.layer.borderColor = UIColor.black.cgColor
        
        //viewToSave.layer.borderWidth = 0.5
        viewToSave.layer.cornerRadius = 5
       // viewToSave.layer.borderColor = UIColor.black.cgColor
        viewToSave.isHidden = true
        
        addPullUpController()
        trackingOutput.isHidden = true
  
        
        //Mark: - Authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        
        
        map.mapType = MKMapType.satelliteFlyover
        map.showsUserLocation = true
        
  
        
 
        
    }
    
    private func addPullUpController() {
        let pullUpController = makeSearchViewControllerIfNeeded()
        addPullUpController(pullUpController, animated: true)
       
        NSLayoutConstraint.activate([
            
            // Anchor Buttons to Pull Up
            buttonView.bottomAnchor.constraint(equalTo: pullUpController.searchBar.topAnchor),

            ])
    }


     // Line from storage in CoreData
    private func polyLine() -> MKPolyline {
        guard let routeLocations = route?.routeLocations else {
            return MKPolyline()
        }

        let coords: [CLLocationCoordinate2D] = routeLocations.map { location in
            let location = location as! RouteLocation
            return CLLocationCoordinate2D(latitude: location.routeLongitude, longitude: location.routeLongitude)
            
            
        }
        
        
        return MKPolyline(coordinates: coords, count: coords.count)
    }

    // Set Region
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            let routeLocations = route?.routeLocations,
            routeLocations.count > 0
            else {
                return nil
        }

        let latitudes = routeLocations.map { routeLocation -> Double in
            let routeLocation = routeLocation as! RouteLocation
            return routeLocation.routeLatitude
        }

        let longitudes = routeLocations.map { routeLocation -> Double in
            let routeLocation = routeLocation as! RouteLocation
            return routeLocation.routeLongitude
        }

        let maxLat = latitudes.max()!
        let minLat = latitudes.min()!
        let maxLong = longitudes.max()!
        let minLong = longitudes.min()!

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                            longitude: (minLong + maxLong) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.3,
                                    longitudeDelta: (maxLong - minLong) * 1.3)
        return MKCoordinateRegion(center: center, span: span)
    }
    
    
//    // To get line from core Data
//    private func loadMap() {
//
//    }
    


    func zoom(to location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    func addStartPin() {
        
        trackingOutput.isHidden = false
        
       
        
        
//        let startFollowPin = CatchAnnotation()
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
   
        
        let stopFollowPin = CatchAnnotation()
        stopFollowPin.title = "Stop"
        stopFollowPin.subtitle = "Path"
        stopFollowPin.pinImageName = "stop"
        
        stopFollowPin.coordinate = CLLocationCoordinate2D(latitude: self.map.userLocation.coordinate.latitude, longitude: self.map.userLocation.coordinate.longitude)
        
        self.locationManager.stopUpdatingLocation()
        self.timer?.invalidate()
        
        viewToSave.isHidden = false
        addACatchButton.isHidden = true
        
        map.showsUserLocation = false
        
        self.map.addAnnotation(stopFollowPin)
        

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
        
        // create NSData from UIImage
//        guard let imageData = mapImageView.image!.jpegData(compressionQuality: 1) else {
//            // handle failed conversion
//            print("jpg error")
//            return
//        }
   
       let newRoute = Routes(context: context)
        newRoute.distance = distance.value
        newRoute.duration = Int16(seconds)
        newRoute.timestamp = Date()
        newRoute.latitude = startFollowPin.coordinate.latitude
        newRoute.longitude = startFollowPin.coordinate.longitude
      //  newRoute.imageData = imageData
        
        for routeLocation in locationList {
            let locationObject = RouteLocation(context: context)
            locationObject.timestamp = routeLocation.timestamp
            locationObject.routeLatitude = routeLocation.coordinate.latitude
            locationObject.routeLongitude = routeLocation.coordinate.longitude
            newRoute.addToRouteLocations(locationObject)
            
           (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
        }
   
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
    
    func addPaths() {
        
        
        map.addAnnotations(pathAnnotations)
        

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
    
    @IBAction func saveButtPressed(_ sender: Any) {
        
        saveRun()
        takeSnapShot()
        viewToSave.isHidden = true
        addACatchButton.isHidden = false
        
        map.showsUserLocation = true
    }
    
    @IBAction func dontSaveButtPressed(_ sender: Any) {
        
        trackingOutput.isHidden = true
        addACatchButton.isHidden = false
        viewToSave.isHidden = true
        addACatchButton.isHidden = false
        
        map.showsUserLocation = true
        
    }
    
    @IBAction func addPinPath(_ sender: Any) {
        addPinToPath()
    }
    

    @IBAction func seePic(_ sender: Any) {
 
        mapImageView.isHidden = true
        performSegue(withIdentifier: "mapPic", sender: self)
    }
    
    // Catch Annotations
    
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
    
    // Path Annotations
    
    func getPathData() -> [MKAnnotation]? {
        
        do {
            storedRoutes = try context.fetch(Routes.fetchRequest())
            
            
//            var pathAnnotations = [MKAnnotation]()
            
            
            for storedRoute in storedRoutes {
                
                let newPathAnno = CatchAnnotation()
                
                newPathAnno.title = "Start Of Route"
                newPathAnno.pinImageName = "start"
                newPathAnno.coordinate.latitude = storedRoute.latitude
                newPathAnno.coordinate.longitude = storedRoute.longitude
                
                pathAnnotations.append(newPathAnno)
          
            }
      
            return pathAnnotations
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
        renderer.lineWidth = 2
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
