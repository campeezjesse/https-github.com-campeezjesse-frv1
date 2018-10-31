//
//  CameraViewController.swift
//  FishRuler
//
//  Created by user1 on 10/5/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import CameraManager
import CoreLocation


class CameraViewController: UIViewController {
    

 
        
        // MARK: - Constants
        
        let cameraManager = CameraManager()
        
        // MARK: - @IBOutlets
       // @IBOutlet weak var headerView: UIView!
        @IBOutlet weak var flashModeImageView: UIImageView!
        @IBOutlet weak var outputImageView: UIImageView!
        @IBOutlet weak var cameraTypeImageView: UIImageView!
    @IBOutlet weak var imageTakenPreview: UIImageView!
    //  @IBOutlet weak var qualityLabel: UILabel!
        
        @IBOutlet weak var cameraView: UIView!
        @IBOutlet weak var askForPermissionsLabel: UILabel!
        
        @IBOutlet weak var footerView: UIView!
        @IBOutlet weak var cameraButton: UIButton!
     //   @IBOutlet weak var locationButton: UIButton!
        
//        let darkBlue = UIColor(red: 4/255, green: 14/255, blue: 26/255, alpha: 1)
        let lightBlue = UIColor(red: 24/255, green: 125/255, blue: 251/255, alpha: 1)
        let redColor = UIColor(red: 229/255, green: 77/255, blue: 67/255, alpha: 1)
//
        // MARK: - UIViewController
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            outputImageView.tintColor = UIColor.white
            flashModeImageView.tintColor = UIColor.white
            
            cameraManager.shouldEnableExposure = true
            
            cameraManager.shouldFlipFrontCameraImage = false
            cameraManager.showAccessPermissionPopupAutomatically = false
            navigationController?.navigationBar.isHidden = true
            
            cameraButton.layer.borderWidth = 5
            cameraButton.layer.cornerRadius = cameraButton.frame.height/2
            cameraButton.layer.borderColor = UIColor.white.cgColor
            cameraButton.layer.masksToBounds = false
            
            
            askForPermissionsLabel.isHidden = true
            askForPermissionsLabel.backgroundColor = lightBlue
            askForPermissionsLabel.textColor = .white
            askForPermissionsLabel.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(askForCameraPermissions))
            askForPermissionsLabel.addGestureRecognizer(tapGesture)
            

            
            let currentCameraState = cameraManager.currentCameraStatus()
            
            if currentCameraState == .notDetermined {
                askForPermissionsLabel.isHidden = false
            } else if currentCameraState == .ready {
                addCameraToView()
            }
            
            flashModeImageView.image = UIImage(named: "flash_off")
            if cameraManager.hasFlash {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeFlashMode))
                flashModeImageView.addGestureRecognizer(tapGesture)
            }
            
            outputImageView.image = UIImage(named: "output_video")
            let outputGesture = UITapGestureRecognizer(target: self, action: #selector(outputModeButtonTapped))
            outputImageView.addGestureRecognizer(outputGesture)
            
            cameraTypeImageView.image = UIImage(named: "switch_camera")
            let cameraTypeGesture = UITapGestureRecognizer(target: self, action: #selector(changeCameraDevice))
            cameraTypeImageView.addGestureRecognizer(cameraTypeGesture)
            
            let imageTakenGesture = UITapGestureRecognizer(target: self, action: #selector(editPhoto))
            imageTakenPreview.addGestureRecognizer(imageTakenGesture)
            
//            qualityLabel.isUserInteractionEnabled = true
//            let qualityGesture = UITapGestureRecognizer(target: self, action: #selector(changeCameraQuality))
//            qualityLabel.addGestureRecognizer(qualityGesture)
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            navigationController?.navigationBar.isHidden = true
            cameraManager.resumeCaptureSession()
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            cameraManager.stopCaptureSession()
        }
        
        
        // MARK: - ViewController
        fileprivate func addCameraToView()
        {
            cameraManager.addPreviewLayerToView(cameraView, newCameraOutputMode: CameraOutputMode.stillImage)
            cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
                
                let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (alertAction) -> Void in  }))
                
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        
        // MARK: - @IBActions
        
        @IBAction func changeFlashMode(_ sender: UIButton) {
            
            switch cameraManager.changeFlashMode() {
            case .off:
                flashModeImageView.image = UIImage(named: "flash_off")
            case .on:
                flashModeImageView.image = UIImage(named: "flash_on")
            case .auto:
                flashModeImageView.image = UIImage(named: "flash_auto")
            }
        }
    
   
        
        @IBAction func recordButtonTapped(_ sender: UIButton) {
            



            switch cameraManager.cameraOutputMode {
            case .stillImage:
                
                cameraManager.capturePictureWithCompletion({ (image, error) -> Void in
                    if error != nil {
                        self.cameraManager.showErrorBlock("Error occurred", "Cannot save picture.")
                    }
                    else {
                        
                        let capturedImage = image
                        
                        self.imageTakenPreview.image = capturedImage
                        
                    //    sender.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                        
                        
                        

                    }
                })
            case .videoWithMic, .videoOnly:
                cameraButton.isSelected = !cameraButton.isSelected
                cameraButton.setTitle("", for: UIControl.State.selected)
                
                
                cameraButton.backgroundColor = redColor
                
                let image = UIImage(named: "recording2")
                
                if sender.isSelected {
                    cameraManager.startRecordingVideo()
                    cameraButton.setImage(image, for: UIControl.State.selected)
                    cameraButton.backgroundColor = UIColor.clear
                    
                    
                    
                    
                } else {
                    cameraManager.stopVideoRecording({ (videoURL, error) -> Void in
                        if error != nil {
                       
                            self.cameraManager.showErrorBlock("Error occurred", "Cannot save video.")
                        }
                    })
                }
            }
        }
        
        
        
//        @IBAction func locateMeButtonTapped(_ sender: Any) {
//            cameraManager.shouldUseLocationServices = true
//            locationButton.isHidden = true
//        }
    
    @IBAction func editPhoto(_ sender: UIButton) {
        
        // Takes image to new vc to edit
        
        let image = imageTakenPreview.image
        
        let vc: ImagePreviewViewController? = self.storyboard?.instantiateViewController(withIdentifier: "ImageVC") as? ImagePreviewViewController
        if let validVC: ImagePreviewViewController = vc,
            let capturedImage = image {
            validVC.image = capturedImage
            validVC.cameraManager = self.cameraManager
            
            self.navigationController?.pushViewController(validVC, animated: true)
        }
        
    }
        
        @IBAction func outputModeButtonTapped(_ sender: UIButton) {
            
            cameraManager.cameraOutputMode = cameraManager.cameraOutputMode == CameraOutputMode.videoWithMic ? CameraOutputMode.stillImage : CameraOutputMode.videoWithMic
            switch cameraManager.cameraOutputMode {
            case .stillImage:
                cameraButton.isSelected = false
                cameraButton.backgroundColor = UIColor.clear
                
                outputImageView.image = UIImage(named: "output_video")
                outputImageView.tintColor = UIColor.black
                
            case .videoWithMic, .videoOnly:
                
                cameraButton.backgroundColor = UIColor.red
                outputImageView.image = UIImage(named: "cameraButton")
                outputImageView.tintColor = UIColor.black
            }
        }
        
        @IBAction func changeCameraDevice() {
            cameraManager.cameraDevice = cameraManager.cameraDevice == CameraDevice.front ? CameraDevice.back : CameraDevice.front
        }
        
        @IBAction func askForCameraPermissions() {
            
            self.cameraManager.askUserForCameraPermission({ permissionGranted in
                self.askForPermissionsLabel.isHidden = true
                self.askForPermissionsLabel.alpha = 0
                if permissionGranted {
                    self.addCameraToView()
                }
            })
        }

    
    @IBAction func goBackToLast(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        
    }
}
    //        @IBAction func changeCameraQuality() {
//            
//            switch cameraManager.changeQualityMode() {
//            case .high:
//                qualityLabel.text = "High"
//            case .low:
//                qualityLabel.text = "Low"
//            case .medium:
//                qualityLabel.text = "Medium"
//            }
//        }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.destination is MeasureViewController{
//
//            let vc = segue.destination as? MeasureViewController
//
//            cameraView = vc?.sceneView
//
//        }
//    }
//}
extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState controlState: UIControl.State) {
        let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
            color.setFill()
            UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
        }
        setBackgroundImage(colorImage, for: controlState)
    }
}
