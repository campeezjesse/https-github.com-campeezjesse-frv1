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
import CoreML
import Vision
import ImageIO

class ImageDisplayViewController: UIViewController, CLLocationManagerDelegate{
    
    var showMyPic = UIImage()
    var length: String = ""
    var date = Date()

    
    let formater = DateFormatter()
    let locationManager = CLLocationManager()
    
   
    @IBOutlet weak var fishLength: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var catchTime: UILabel!
    @IBOutlet weak var showPic: UIImageView!
    @IBOutlet weak var fishSpeciesLabel: UILabel!
    
    // MARK: - Image Classification
    
    
    
    /// - Tag: MLModelSetup
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model = try VNCoreMLModel(for: DefaultCustomModel_2013441993().model )
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    /// - Tag: PerformRequests
    func updateClassifications(for image: UIImage) {
        fishSpeciesLabel.text = "Classifying..."
        
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                /*
                 This handler catches general image processing errors. The `classificationRequest`'s
                 completion handler `processClassifications(_:error:)` catches errors specific
                 to processing that request.
                 */
                print("Not Hotdog.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.fishSpeciesLabel.text = "Not Hotdog.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.fishSpeciesLabel.text = "Not Hotdog"
            } else {
              
                self.fishSpeciesLabel.text = classifications[0].identifier
            }
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()

       
    }
  
}
extension ImageDisplayViewController {
    fileprivate func setupView() {
        showPic.image = showMyPic
        fishLength.text = length
        fishSpeciesLabel.lineBreakMode = .byWordWrapping
        formater.dateFormat = "MM/dd/yyyy   hh:mm"
        let result = formater.string(from: date)
        catchTime.text = result
        
        let image = showMyPic
        showPic.image = image
        updateClassifications(for: image)
        
        var currentLocation: CLLocation!
        
        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways){
            
            currentLocation = locationManager.location
            
           latitudeLabel.text = "\(currentLocation.coordinate.latitude)"
            
            longitudeLabel.text = "\(currentLocation.coordinate.longitude)"
        }
      
        }
    }

