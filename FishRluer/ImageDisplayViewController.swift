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
import ForecastIO

class ImageDisplayViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    

    var fishKind: String? = ""
    var length: String? = "Length: "
    var date = Date()
    var waterTempDepth: String? = ""
    var bait: String? = ""
    var weatherCond: String? = ""
    var notes: String? = ""
    

   
    
    let formater = DateFormatter()
    let locationManager = CLLocationManager()
    
    var pointAnnotation: CatchAnnotation!
    var pinAnnotationView: MKAnnotationView!
    
    
    fileprivate lazy var isRecording: Bool = false
    
   
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var fishLength: UITextField!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var fishSpeciesLabel: UITextField!
    @IBOutlet weak var catchTime: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addToMapButton: UIButton!
    @IBOutlet weak var baitUsed: UITextField!
    @IBOutlet weak var currentWeather: UITextField!
    @IBOutlet weak var moreNotes: UITextView!
    @IBOutlet weak var waterTempConditions: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var theTemp: UILabel!
    @IBOutlet weak var theSummary: UILabel!
    @IBOutlet weak var theWind: UILabel!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var fish: Fish?
    private var locationList: [CLLocation] = []
    
    
    let client = DarkSkyClient(apiKey: "0c6c3aca0c9f41065a7bffbedaa74dcd")
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        
        
        // setup keyboard event
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
       
       

        
        
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
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(notification:NSNotification){
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        scrollView.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
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
        let region = MKCoordinateRegion.init(center: center, span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
        mapView.setRegion(region, animated: true)
        
        pointAnnotation = CatchAnnotation()
        pointAnnotation.pinImageName = "pin"
        pointAnnotation.coordinate = catchLocation
        pointAnnotation.title = length
        pointAnnotation.subtitle = catchTime.text
    
        //catchTime.text becomes annotation subtitle. This is used as objectID for selected annotation in mapView
        
        pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        
        mapView.addAnnotation(pinAnnotationView.annotation!)
        
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("need location")
       
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
        annotationView?.image = UIImage(named: "pin2")
        
        return annotationView
    }
    

    
    @IBAction func addInfo(_ sender: UIButton) {
        
  
        if CLLocationManager.locationServicesEnabled() {


            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                let alert = UIAlertController(title: "Location Needed", message: "There was an error finding you!", preferredStyle: .alert)

                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
                alert.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alert.addAction(cancelAction)

                present(alert, animated: true, completion: nil)


            case .authorizedAlways, .authorizedWhenInUse:
        


    //this is where we set the information to be saved into the coreData model named "Fish"
    
        let fishKind = fishSpeciesLabel.text
        let waterTempDepth = waterTempConditions.text
        let bait =  baitUsed.text
        let weatherCond = currentWeather.text
        let notes = moreNotes.text
        let catchTimeandDate = catchTime.text
        let catchLength = fishLength.text
        let catchWind = theWind.text
        let catchTemp = theTemp.text
        let catchWeatherSum = theSummary.text
    

         let myCoordinate = pointAnnotation.coordinate
       

        let newPin = Fish(context: context)
        
        newPin.latitude = myCoordinate.latitude
        newPin.longitude = myCoordinate.longitude
        newPin.species = fishKind
        newPin.length = catchLength
        newPin.water = waterTempDepth
        newPin.bait = bait
        newPin.weather = weatherCond
        newPin.notes = notes
        newPin.time = catchTimeandDate
        newPin.currentTemp = catchTemp
        newPin.weatherSummary = catchWeatherSum
        newPin.windSpeed = catchWind
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
       
        let alert = UIAlertController(title: "Saved!", message: "See your fish on the map, or continue catching", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
       // alert.addAction(UIAlertAction(title: "Go to map", style: .default, handler: {action in self.performSegue(withIdentifier: "addInfoToMap", sender: self)
        
           
       // }))
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)

            

                }
            func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
                print("need location")
                
        }
    }
    
}
    

    @IBAction func goBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
        
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
         //   let time = catchTime.text
           
            
            mapVC?.fishKind = fishKind
            mapVC?.waterTempDepth = waterTempDepth
            mapVC?.bait = bait
            mapVC?.weatherCond = weatherCond
            mapVC?.notes = notes
            
            mapVC?.catchTitle = catchTitle!
            mapVC?.catchSubTitle = catchSubTitle!
            mapVC?.catchSpecies = catchSpecies!
            
            mapVC?.catchID = catchSubTitle!

            
     
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
        
        fishLength.text = length
        
        
        
        var currentLocation: CLLocation?
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways){
            
            currentLocation = locationManager.location
            
            if let myLat = currentLocation?.coordinate.latitude {
            
            latitudeLabel.text = "\(myLat)"
            }
            
            if let myLong = currentLocation?.coordinate.longitude {
                
            longitudeLabel.text = "\(myLong)"
        }
       
            let myLat = currentLocation?.coordinate.latitude
            let myLong = currentLocation?.coordinate.longitude
            
       
            client.getForecast(latitude: myLat!, longitude: myLong!) { result in
                switch result {
                    
                case .success(let currentForecast, let requestMetadata):
                    if let currentTemp: Double = currentForecast.currently?.temperature {
//                        print(currentTemp)

                        DispatchQueue.main.async {
                            self.theTemp.text = String(Int(round(currentTemp))) + "˚F"
                        }
                       
                    
                    if let summaryInfo: String = currentForecast.currently?.summary {
                        print(summaryInfo)
                        DispatchQueue.main.async {
                            self.currentWeather.text = summaryInfo  + " " + String(Int(round(currentTemp))) + "˚F"
                        }
                        }
                         if let wind: Double = currentForecast.currently?.windSpeed {
                            DispatchQueue.main.async {
                                self.theWind.text = String(Int(round(wind))) + "MPH Winds"
                    }
                    }
                        if let summaryInfo: String = currentForecast.currently?.summary {
                            print(summaryInfo)
                            DispatchQueue.main.async {
                                self.theSummary.text = summaryInfo
                            }
                        }
                    }
                    print(requestMetadata)
                    
                case .failure(let error):
                    
                    print(error)
                }
            }
    }
}
    
}
