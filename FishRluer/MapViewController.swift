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
    
    // Drawing a line to follow
    let startPin = MKPointAnnotation()
    private var route: Routes?
    private var seconds = 0
    private var timer: Timer?
    private var distance = Measurement(value: 0, unit: UnitLength.meters)
    private var locationList: [CLLocation] = []
   
    

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
        startFollowButton.layer.borderWidth = 0.25
        startFollowButton.layer.cornerRadius = startFollowButton.frame.height/2
        startFollowButton.layer.borderColor = UIColor.lightGray.cgColor
        
        stopFollowingButton.layer.borderWidth = 0.25
        stopFollowingButton.layer.cornerRadius = stopFollowingButton.frame.height/2
        stopFollowingButton.layer.borderColor = UIColor.lightGray.cgColor
        stopFollowingButton.isHidden = true
        
        addACatchButton.layer.borderWidth = 0.25
        addACatchButton.layer.cornerRadius = addACatchButton.frame.height/2
        addACatchButton.layer.borderColor = UIColor.lightGray.cgColor
        
        
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
            
            buttonView.bottomAnchor.constraint(equalTo: pullUpController.searchBar.topAnchor),
//            purpleView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
//            purpleView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
            ])
    }
    
    
    func zoom(to location: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion.init(center: location, span: span)
        
        map.setRegion(region, animated: true)
    }
    
    func addStartPin() {
        
        trackingOutput.isHidden = false
        
        let startFollowPin = MKPointAnnotation()
        startFollowPin.title = "Start"
        startFollowPin.subtitle = "On the journey to more fish"
        
        startFollowPin.coordinate = CLLocationCoordinate2D(latitude: map.userLocation.coordinate.latitude, longitude: map.userLocation.coordinate.longitude)
        
        //locationManager.startUpdatingLocation()
       
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
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            
            self.saveRun()
            
           
            
            
            
        })
        alertController.addAction(UIAlertAction(title: "Discard", style: .destructive) { _ in
            
            _ = self.navigationController?.popToRootViewController(animated: true)
        })
        
        present(alertController, animated: true)
        
        let stopFollowPin = MKPointAnnotation()
        stopFollowPin.title = "The End"
        stopFollowPin.subtitle = "But only for now!"

        stopFollowPin.coordinate = CLLocationCoordinate2D(latitude: map.userLocation.coordinate.latitude, longitude: map.userLocation.coordinate.longitude)

        locationManager.stopUpdatingLocation()
        timer?.invalidate()

        map.addAnnotation(stopFollowPin)
    }
    
    func takeSnapShot() {
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        // Set the region of the map that is rendered. (by one specified coordinate)
        // let location = CLLocationCoordinate2DMake(24.78423, 121.01836) // Apple HQ
        // let region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000)
        
        // Set the region of the map that is rendered. (by polyline)
         var yourCoordinates = [CLLocationCoordinate2D]()
        let polyLine = MKPolyline(coordinates: &yourCoordinates, count: yourCoordinates.count)
        let region = MKCoordinateRegion(polyLine.boundingMapRect)
        
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width: 300, height: 300)
        
        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapShotter.start() { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }
//            self.imageView.image = snapshot.image
        }
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
            let locationObject = Location(context: CoreDataStack.context)
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            newRoute.addToLocations(locationObject)
        }
        
        CoreDataStack.saveContext()
        
        route = newRoute
    }
    
    func addCatchPins() {
        
                if let annotations = getData() {
                    map.addAnnotations(annotations)
                }
        
    }
    
    func removeCatchPins() {
     
        map.removeAnnotations(map.annotations)
            
    
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
    
    @IBAction func addCatch(_ sender: Any) {
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
    // Use This Later
//        func mapView (_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
//        {
//            if (annotation is MKUserLocation) {
//                return nil
//            }
//            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: "annId")
//            
//            if anView == nil {
//                anView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annId")
//            }
//            else {
//                anView?.annotation = annotation
//            }
//            
//            anView?.canShowCallout = true
//            
//            if (annotation.subtitle! == "Offline") {
//                anView?.image = UIImage(named: "offIceCream.pdf")
//            }
//            else if (annotation.subtitle! == "Online") {
//                anView?.image = UIImage(named: "onIceCream.pdf")
//            }
//            return anView
//        }


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
        renderer.strokeColor = .blue
        renderer.lineWidth = 3
        return renderer
    }
}
