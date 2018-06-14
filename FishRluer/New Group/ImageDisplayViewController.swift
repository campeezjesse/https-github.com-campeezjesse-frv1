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

class ImageDisplayViewController: UIViewController, CLLocationManagerDelegate{
    
    var showMyPic = UIImage()
    var length: String = ""
    var date = Date()
    
    
    let formater = DateFormatter()
    let locationManager = CLLocationManager()
   
    @IBOutlet weak var fishLength: UILabel!

    @IBOutlet weak var catchTime: UILabel!
    
    @IBOutlet weak var showPic: UIImageView!
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
       
       
        
    }
   
  
}
extension ImageDisplayViewController {
    fileprivate func setupView() {
        showPic.image = showMyPic
        fishLength.text = length
        
        formater.dateFormat = "mm/dd/yyyy hh:mm"
        let result = formater.string(from: date)
        catchTime.text = result
        
        
        }
    }

