//
//  ImageDisplayViewController.swift
//  FishRuler
//
//  Created by user1 on 6/7/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import ReplayKit
import CoreData

class ImageDisplayViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    
    var showMyPic = UIImage()
    var fishKind: String = ""
    var length: String = ""
    var date = Date()
    var waterTempDepth: String = ""
    var bait: String = ""
    var weatherCond: String = ""
    var notes: String = ""
    

   

    let formater = DateFormatter()
    let locationManager = CLLocationManager()
    
    var pointAnnotation: CatchAnnotation!
    var pinAnnotationView: MKAnnotationView!
    
    
    fileprivate lazy var isRecording: Bool = false
    
   
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fishLength: UITextField!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var showPic: UIImageView!
    @IBOutlet weak var fishSpeciesLabel: UITextField!
    @IBOutlet weak var catchTime: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addToMapButton: UIButton!
    @IBOutlet weak var baitUsed: UITextField!
    @IBOutlet weak var currentWeather: UITextField!
    @IBOutlet weak var moreNotes: UITextView!

    @IBOutlet weak var waterTempConditions: UITextField!
    
  
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var fish: Fish?
    private var locationList: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        
        setupView()
        
        //Mark: - Authorization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        mapView.mapType = MKMapType.standard
        mapView.showsUserLocation = true
       
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        if locations.count > 0 {
            
            manager.stopUpdatingLocation()
        }
        
       
        
        let location = locations.last! as CLLocation
        let catchLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let center = catchLocation
        let region = MKCoordinateRegionMake(center, MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        mapView.setRegion(region, animated: true)
        
        pointAnnotation = CatchAnnotation()
        pointAnnotation.pinImageName = "pin"
        pointAnnotation.coordinate = catchLocation
        pointAnnotation.title = length
        pointAnnotation.subtitle = catchTime.text
    
        
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        
        mapView.addAnnotation(pinAnnotationView.annotation!)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
       
    }
    
    //MARK: - Custom Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
       
       
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
            
            
        } else {
            annotationView?.annotation = annotation
        }
        
       // let catchAnnotation = annotation as! CatchAnnotation
        annotationView?.image = UIImage(named: "pin2")
        
        return annotationView
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


    
        
    @IBAction func addInfo(_ sender: UIButton) {
    
   
    
        let fishKind = fishSpeciesLabel.text!
        let waterTempDepth = waterTempConditions.text!
        let bait =  baitUsed.text!
        let weatherCond = currentWeather.text!
        let notes = moreNotes.text!
        let catchTimeandDate = catchTime.text!
    

        let coordinate = pointAnnotation.coordinate

        let newPin = Fish(context: context)
        newPin.latitude = coordinate.latitude
        newPin.longitude = coordinate.longitude
        newPin.species = fishKind
        newPin.length = length
        newPin.water = waterTempDepth
        newPin.bait = bait
        newPin.weather = weatherCond
        newPin.notes = notes
        newPin.time = catchTimeandDate
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        print("saved bitches")
        
        let alert = UIAlertController(title: "Saved!", message: "See your fish on the map, or continue catching", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(UIAlertAction(title: "Go to map", style: .default, handler: {action in self.performSegue(withIdentifier: "showCatchDetails", sender: self)}))
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)

    }
    
        
    
    @IBAction func goBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MapViewController{
            
            let mapVC = segue.destination as? MapViewController
        
            let catchTitle = pointAnnotation.title
            let catchSubTitle = pointAnnotation.subtitle
            let catchSpecies = fishSpeciesLabel.text
            
            let fishKind = fishSpeciesLabel.text!
            let waterTempDepth = waterTempConditions.text!
            let bait =  baitUsed.text!
            let weatherCond = currentWeather.text!
            let notes = moreNotes.text!
           
            
            mapVC?.fishKind = fishKind
            mapVC?.waterTempDepth = waterTempDepth
            mapVC?.bait = bait
            mapVC?.weatherCond = weatherCond
            mapVC?.notes = notes
            
            mapVC?.catchTitle = catchTitle!
            mapVC?.catchSubTitle = catchSubTitle!
            mapVC?.catchSpecies = catchSpecies!
            

        }
    }
}
    
extension ImageDisplayViewController {
    fileprivate func setupView() {
        
        
        formater.dateFormat = "MM/dd/yyyy 'at'  hh:mm a"
        formater.amSymbol = "AM"
        formater.pmSymbol = "PM"
        
        let result = formater.string(from: date)
        
        catchTime.text = result
        
        let image = showMyPic
        showPic.image = image
       
        
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways){
            
            currentLocation = locationManager.location
            
           latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
            
            longitudeLabel.text = "\(currentLocation.coordinate.longitude)"
        }
       
    }
}

