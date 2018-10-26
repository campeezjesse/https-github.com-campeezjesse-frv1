//
//  HomeViewController.swift
//  FishRuler
//
//  Created by user1 on 10/4/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {
    
    let locationManager = CLLocationManager()

    @IBOutlet weak var addToMap: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button for bottom of initial vc
        addToMap.layer.borderWidth = 5
        addToMap.layer.borderColor = UIColor.black.cgColor
        addToMap.layer.cornerRadius = 5
        addToMap.layer.masksToBounds = true
        
        // Hide the nav bar it f-s up the top area
navigationController?.setNavigationBarHidden(true, animated: false)

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageDisplayViewController{
            
           // let vc = segue.destination as? ImageDisplayViewController
            
            
            
           // vc?.length = "Size: "
            
        }
    }

    
    func enableLocationServices() {
        locationManager.delegate = self as? CLLocationManagerDelegate
        
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
            
        case .authorizedAlways:
            enableLocationServices()
        case .authorizedWhenInUse:
            enableLocationServices()
        }
    }
}
