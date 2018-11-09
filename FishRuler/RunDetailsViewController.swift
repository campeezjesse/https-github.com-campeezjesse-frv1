//
//  RunDetailsViewController.swift
//  FishRuler
//
//  Created by user1 on 11/6/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RunDetailsViewController: UIViewController, MKMapViewDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var fishCaughtLabel: UILabel!
    
    var run: Routes!
    var myFish: Fish!
    
    var routeID: String = ""
    var myCatchID: String = ""
    
    var catches = [MKAnnotation]()
    var myCatches: [Fish]! = []
    
    var numOfCatches = 0
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        addCatchPins()
        
 
    }
    
    
    private func configureView() {
        
        let ID = routeID
        
        do{
            let request: NSFetchRequest<Routes> = Routes.fetchRequest()
            let predicate = NSPredicate(format: "date == %@", ID)
            request.predicate = predicate
            
            let locations = try self.context.fetch(request)
            for location in locations{
                
                let distance = Measurement(value: location.distance, unit: UnitLength.meters)
                let seconds = Int(location.duration)
                let formattedDistance = FormatDisplay.distance(distance)
                let formattedDate = FormatDisplay.date(location.timestamp)
                let formattedTime = FormatDisplay.time(seconds)
                let formattedPace = FormatDisplay.pace(distance: distance,
                                                       seconds: seconds,
                                                       outputUnit: UnitSpeed.minutesPerMile)
                //let formatedCatches = numOfCatches
                
                distanceLabel.text = "Distance:  \(formattedDistance)"
                dateLabel.text = formattedDate
                timeLabel.text = "Time:  \(formattedTime)"
                paceLabel.text = "Pace:  \(formattedPace)"
                //fishCaughtLabel.text = "Fish Caught: \(formatedCatches)"
                
                run = location
                
                location.date = routeID
           
                loadMap()
            
              // print(myCatchID)
                
 
            }
        } catch {
            print("Failed")
        }
}

    private func showCatch() -> [MKAnnotation]? {
        
        let catchID = myCatchID
        
        do{
            let request: NSFetchRequest<Fish> = Fish.fetchRequest()
            let predicate = NSPredicate(format: "annoID == %@", catchID)
            request.predicate = predicate

            var catches = [MKAnnotation]()
            
         myCatches = try self.context.fetch(request)
            for myCatch in myCatches{
                
                let  catchAnno = CatchAnnotation()
                let species = myCatch.species
                let theTime = myCatch.time
                let catchLat = myCatch.latitude
                let catchLong = myCatch.longitude

                catchAnno.title = species
                catchAnno.subtitle = theTime
                catchAnno.pinImageName = "catch"
                
                catchAnno.coordinate = CLLocationCoordinate2D(latitude: catchLat, longitude: catchLong)
                
                
                catches.append(catchAnno)
                
                
//                formatedCatches = catches.count
//                print(formatedCatches)
          
               //  myFish = myCatch
                
            }
            
            return catches
            
        } catch {
            print("Failed")
        }
        return nil
    }

    func addCatchPins() {


        if let catchAnno = showCatch() {
            mapView.addAnnotations(catchAnno)
            
            numOfCatches = mapView.annotations.count
            print(numOfCatches)
            
            fishCaughtLabel.text = "Fish Caught: \(numOfCatches)"
        }
    }

    
    private func mapRegion() -> MKCoordinateRegion? {
        guard
            let locations = run.routeLocations,
            locations.count > 0
            else {
                return nil
        }
        
        let latitudes = locations.map { location -> Double in
            let location = location as! RouteLocation
            return location.routeLatitude
        }
        
        let longitudes = locations.map { location -> Double in
            let location = location as! RouteLocation
            return location.routeLongitude
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
    
    private func polyLine() -> [MulticolorPolyline] {
        
        // 1
        let locations = run.routeLocations?.array as! [RouteLocation]
        var coordinates: [(CLLocation, CLLocation)] = []
        var speeds: [Double] = []
        var minSpeed = Double.greatestFiniteMagnitude
        var maxSpeed = 0.0
        
        // 2
        for (first, second) in zip(locations, locations.dropFirst()) {
            let start = CLLocation(latitude: first.routeLatitude, longitude: first.routeLongitude)
            let end = CLLocation(latitude: second.routeLatitude, longitude: second.routeLongitude)
            
            coordinates.append((start, end))
            
            //3
            let distance = end.distance(from: start)
            let time = second.timestamp!.timeIntervalSince(first.timestamp! as Date)
            let speed = time > 0 ? distance / time : 0
            speeds.append(speed)
            minSpeed = min(minSpeed, speed)
            maxSpeed = max(maxSpeed, speed)

        }
        
      
        
        //5
        var segments: [MulticolorPolyline] = []
        for ((start, end), _) in zip(coordinates, speeds) {
            let coords = [start.coordinate, end.coordinate]
            let segment = MulticolorPolyline(coordinates: coords, count: 2)
            segment.color = UIColor.black
            segments.append(segment)
        }
        return segments
    }
    
    private func loadMap() {
        guard
            let locations = run.routeLocations,
            locations.count > 0,
            let region = mapRegion()
            
            else {
                let alert = UIAlertController(title: "Error",
                                              message: "Sorry, this run has no locations saved",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                present(alert, animated: true)
                return
        }
        
        mapView.setRegion(region, animated: true)
        mapView.addOverlays(polyLine())
        //mapView.addAnnotations(catches)
    }
    
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
        // let catchAnnotation = annotation as! CatchAnnotation
        annotationView?.image = UIImage(named: "catch")
        
        return annotationView
    }
 
    

    @IBAction func deletePath(_ sender: Any) {
        let alert = UIAlertController(title: "Are You Sure?", message: "Any changes are permenate!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteDataAction = UIAlertAction(title: "delete", style: .destructive, handler: { action in
            
            let pathID = self.routeID
            
            do{
                let request: NSFetchRequest<Routes> = Routes.fetchRequest()
                let predicate = NSPredicate(format: "date == %@", pathID)
                request.predicate = predicate
                
                let locations = try self.context.fetch(request)
                for location in locations{
                    self.context.delete(location)
                   
                    
                }
            } catch {
                print("Failed")
            }
            
            do {
                try self.context.save()
                
                DispatchQueue.main.asyncAfter(deadline:.now() + 0.75, execute: {
                    self.dismiss(animated: true, completion: nil)
                    
                    
                })
                
                
            } catch {
                print("Failed saving")
            }
            
        })
        
        
        alert.addAction(cancelAction)
        alert.addAction(deleteDataAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    

    
    @IBAction func backPressed(_ sender: Any) {
        if let presenter = presentingViewController as? MapViewController {
            
            presenter.removeCatchPins()
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
}

// MARK: - Map View Delegate

extension RunDetailsViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyline = overlay as? MulticolorPolyline else {
            return MKOverlayRenderer(overlay: overlay)
        }
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.strokeColor = polyline.color
        renderer.lineWidth = 3
        return renderer
    }
    

}

