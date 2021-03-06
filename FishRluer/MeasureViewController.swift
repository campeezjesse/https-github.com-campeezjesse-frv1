//
//  MeasureViewController.swift
//  FishRluer
//
//  Created by user1 on 5/29/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import ReplayKit
import NVActivityIndicatorView


final class MeasureViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var saveImageButton: UIButton!
    @IBOutlet weak var outputImageView: UIImageView!
 //   @IBOutlet weak var titleView: UIView!

    @IBOutlet weak var pressToStopRecLabel: UILabel!
 
    @IBOutlet weak var startStopView: UIView!
    @IBOutlet weak var startMeasureButton: UIButton!
    @IBOutlet weak var stopMeasureButton: UIButton!

    @IBOutlet weak var buttonViewParent: UIView!
    @IBOutlet weak var recAnimation: NVActivityIndicatorView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var saveDetailsButton: UIButton!
   // @IBOutlet weak var saveDetailsLabel: UILabel!
 
    @IBOutlet weak var photoTaken: UIButton!
    fileprivate lazy var session = ARSession()
    fileprivate lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    fileprivate lazy var isMeasuring = false;
    fileprivate lazy var vectorZero = SCNVector3()
    fileprivate lazy var startValue = SCNVector3()
    fileprivate lazy var endValue = SCNVector3()
    fileprivate lazy var lines: [Line] = []
    fileprivate var currentLine: Line?
    fileprivate lazy var unit: DistanceUnit = .inch
    fileprivate lazy var isRecording: Bool = false
    
   
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        
        checkCameraAccess()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.run(sessionConfiguration, options: [.resetTracking])
   
        resetValues()
    }

    
    @IBAction func startMeasurePressed(_ sender: Any) {
   
        
        resetValues()
        isMeasuring = true
        targetImageView.image = UIImage(named: "targetGreen")
        startMeasureButton.isHidden = true
        stopMeasureButton.isHidden = false
        
            
        }
    

    @IBAction func stopMeasurePressed(_ sender: Any) {
  
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
            resetButton.isHidden = false
            startMeasureButton.isHidden = true
            targetImageView.isHidden = true
            stopMeasureButton.isHidden = true
            

            
       
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageDisplayViewController{
            
            let vc = segue.destination as? ImageDisplayViewController
            
            
           // let myPic = sceneView.snapshot()
           
            vc?.length = messageLabel.text!
            
            
            session.pause()
            

            
        }
    }
    
    func checkCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied:
            print("Denied, request permission from settings")
            presentCameraSettings()
        case .restricted:
            print("Restricted, device owner must approve")
        case .authorized:
            print("Authorized, proceed")
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success {
                    print("Permission granted, proceed")
                } else {
                    print("Permission denied")
                }
            }
        }
    }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
    }
    
    func startRecording() {
        
  
        if RPScreenRecorder.shared().isAvailable {
            
            
            RPScreenRecorder.shared().startRecording(handler: { (error) in
                if error == nil {
                    print("recording")
                    
                } else {
                    print(error ?? "")
                    self.messageLabel.text = "Error recording occurred"
                }
            })
        }
    }

    func stopRecording() {
       
        RPScreenRecorder.shared().stopRecording { [unowned self] (previewController, error) in
            if error == nil {
                
                print("recording ended")
                
                let alertController = UIAlertController(title: "Done", message: "You can view your video to edit and share, or delete to try again", preferredStyle: .alert)
                
                let discardAction = UIAlertAction(title: "Delete", style: .default) { (action: UIAlertAction) in
                    RPScreenRecorder.shared().discardRecording(handler: { () -> Void in
                        // Executed once recording has successfully been discarded
                    })
                }
                
                let viewAction = UIAlertAction(title: "View", style: .default, handler: { (action) in
                    previewController?.previewControllerDelegate = self
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


    @IBAction func takePic(_ sender: Any) {
       outputImageView.image = sceneView.snapshot()
        photoTaken.isHidden = false
        saveImageButton.isEnabled = true
      


        let alert = UIAlertController(title: "Nice Catch!", message: "What would you like to do with the picture?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)

        alert.addAction(UIAlertAction(title: "Save to photos", style: .default, handler: {action in self.savePic(alert)}))
        
        alert.addAction(UIAlertAction(title: "Add more info and save on map ", style: .default, handler: {action in self.performSegue(withIdentifier: "saveDetails", sender: self)}))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in self.removePreview(alert)}))
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
   
    }
    
   
    @IBAction func addDetails(_ sender: Any) {

    }
    
    


    @IBAction func savePic(_ sender: Any) {
        let pic = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(pic, self, nil, nil)
      
        
        // the alert view
        let alert = UIAlertController(title: "Saved to phone", message: "so you can show it off later!", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when){
            // your code with delay
            alert.dismiss(animated: true, completion: nil)
        }
        
           
    }
    func removePreview(_ sender: Any) {
        outputImageView.isHidden = true
        saveImageButton.isHidden = true
    }
    
    @IBAction func showAlertToSave(_ sender: Any) {
        
        let alert = UIAlertController(title: "Ready To Save", message: "Save your picture to show off", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
      
        
        alert.addAction(UIAlertAction(title: "Save to photos", style: .default, handler: {action in self.savePic(alert)}))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .default, handler: {action in self.removePreview(alert)}))
      
        alert.addAction(cancelAction)
      
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func swipeForCamera(_ sender: Any) {
        
        let cameraController = storyboard?.instantiateViewController(withIdentifier: "camera")
        
        addChild(cameraController!)
        view.addSubview((cameraController?.view)!)
        cameraController?.didMove(toParent: self)
        
        
    }
}

// MARK: - ARSCNViewDelegate

extension MeasureViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
            
           
            
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        messageLabel.text = "Looking For Camera"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        messageLabel.text = "Interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        messageLabel.text = "Interruption ended"
    }
}

// MARK: - Users Interactions

extension MeasureViewController {
    @IBAction func meterButtonTapped(button: UIButton) {
        let alertVC = UIAlertController(title: "Settings", message: "Please select distance unit options", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: DistanceUnit.centimeter.title, style: .default) { [weak self] _ in
            self?.unit = .centimeter
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.inch.title, style: .default) { [weak self] _ in
            self?.unit = .inch
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.meter.title, style: .default) { [weak self] _ in
            self?.unit = .meter
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func resetButtonTapped(button: UIButton) {
  
        for line in lines {
            line.removeFromParentNode()
        }
        lines.removeAll()
        startMeasureButton.isHidden = false
        stopMeasureButton.isHidden = true
        outputImageView.isHidden = true
        saveImageButton.isHidden = true
        photoTaken.isHidden = true
        targetImageView.isHidden = false
    }
    
    
}

// MARK: - Privates

extension MeasureViewController {
    fileprivate func setupScene() {
        targetImageView.isHidden = true
        sceneView.delegate = self
        sceneView.session = session
        loadingView.startAnimating()
     
        messageLabel.text = "Looking for your fish..."
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        resetButton.isHidden = true
        startStopView.isHidden = true
        startMeasureButton.isHidden = false
        stopMeasureButton.isHidden = true
        cameraButton.isHidden = false
        pressToStopRecLabel.isHidden = true
     saveImageButton.isEnabled = false
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
     
        
        self.startMeasureButton.layer.borderWidth = 5
        self.startMeasureButton.layer.borderColor = UIColor.white.cgColor
        self.startMeasureButton.layer.cornerRadius = 5
        self.startMeasureButton.layer.masksToBounds = true
        
        self.stopMeasureButton.layer.borderWidth = 5
        self.stopMeasureButton.layer.borderColor = UIColor.white.cgColor
        self.stopMeasureButton.layer.cornerRadius = 5
        self.stopMeasureButton.layer.masksToBounds = true
        
       cameraButton.layer.borderWidth = 8
        cameraButton.layer.cornerRadius = cameraButton.frame.height/2
        cameraButton.layer.borderColor = UIColor.white.cgColor
        cameraButton.layer.masksToBounds = false
        

    
        // Add "long" press gesture recognizer
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 0.3
        cameraButton.addGestureRecognizer(tap)
    }
    
    // called by gesture recognizer
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        
      
        // handle touch down and touch up events separately
        if gesture.state == .began {
            cameraButton.isHidden = true
            recAnimation.isHidden = false
            pressToStopRecLabel.isHidden = false
            recAnimation.startAnimating()
           startRecording()
     
            
        } else if  gesture.state == .ended {
            print("touch ended")
       stopRecording()
            recAnimation.isHidden = true
            pressToStopRecLabel.isHidden = true
            recAnimation.stopAnimating()
            cameraButton.isHidden = false 
        }
    }
    
    fileprivate func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
        
        stopMeasureButton.isHidden = true
    }
    
    fileprivate func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
        targetImageView.isHidden = false
        resetButton.isHidden = false
        startStopView.isHidden = false
        
       
        if lines.isEmpty {
            messageLabel.text = "Get Length"
        }
        loadingView.stopAnimating()
  
        if isMeasuring {
            if startValue == vectorZero {
                startValue = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
                
            }
            endValue = worldPosition
            currentLine?.update(to: endValue)
            messageLabel.text = currentLine?.distance(to: endValue) ?? "Calculating…"
        }

    }
}
extension MeasureViewController: RPPreviewViewControllerDelegate {
    public func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true, completion: nil)
    }
    
    
    /* @abstract Called when the view controller is finished and returns a set of activity types that the user has completed on the recording. The built in activity types are listed in UIActivity.h. */
    public func previewController(_ previewController: RPPreviewViewController, didFinishWithActivityTypes activityTypes: Set<String>) {
        
    }
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
