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

   // @IBOutlet weak var savePicToPhone: UILabel!

    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var outputImageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
//    @IBOutlet weak var recVid: UIButton!
//    @IBOutlet weak var stopButton: UIButton!
//    @IBOutlet weak var pressToRecLabel: UILabel!
    @IBOutlet weak var pressToStopRecLabel: UILabel!
    

   // @IBOutlet weak var savePicButton: UIButton!

    @IBOutlet weak var startMeasureButton: UIButton!
    @IBOutlet weak var stopMeasureButton: UIButton!

    @IBOutlet weak var buttonViewParent: UIView!
    @IBOutlet weak var recAnimation: NVActivityIndicatorView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var saveDetailsButton: UIButton!
    @IBOutlet weak var saveDetailsLabel: UILabel!
    

//    @IBOutlet weak var photoTakenButton: UIButton!
    @IBOutlet weak var photoTaken: UIButton!
  //  @IBOutlet weak var pointAtFishLabel: UILabel!
    
   // @IBOutlet weak var cameraButton: UIButton!
  //  @IBOutlet weak var cameraButtonImage: UIImageView!
    
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
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
        session.run(sceneView.session.configuration!)
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
            
//            // the alert view
//            let alert = UIAlertController(title: "Take Picture", message: "to add details about fish and save to map", preferredStyle: .alert)
//            self.present(alert, animated: true, completion: nil)
//
//            // change to desired number of seconds (in this case 5 seconds)
//            let when = DispatchTime.now() + 1
//            DispatchQueue.main.asyncAfter(deadline: when){
//                // your code with delay
//                alert.dismiss(animated: true, completion: nil)
//            }
            
       
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageDisplayViewController{
            
            let vc = segue.destination as? ImageDisplayViewController
            let vc2 = segue.destination as? PicturePreviewViewController
            
            let myPic = sceneView.snapshot()
            vc2?.showMyPic = myPic
            vc?.length = messageLabel.text!
            
            
            session.pause()
            
//            if segue.destination is PicturePreviewViewController{
//
//                let vc2 = segue.destination as? PicturePreviewViewController
//
//                let myPic = outputImageView.image
//                vc2?.showMyPic = myPic!
//
//                session.pause()
       //     }
            
        }
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
       // photoTakenButton.isHidden = false
      //  savePicButton.isHidden = false
      //  savePicToPhone.isHidden = false
        


        let alert = UIAlertController(title: "Nice Catch!", message: "What would you like to do with the picture?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        
        
        alert.addAction(UIAlertAction(title: "Save pic and add info", style: .default, handler: {
            action in self.performSegue(withIdentifier: "saveDetails", sender: self)
            self.savePic(alert)
        }))
        
        alert.addAction(UIAlertAction(title: "Save to photos", style: .default, handler: {action in self.savePic(alert)}))
        
        alert.addAction(UIAlertAction(title: "Add more info and save on map ", style: .default, handler: {action in self.performSegue(withIdentifier: "saveDetails", sender: self)}))
        
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
   
    }
    
   
    @IBAction func addDetails(_ sender: Any) {
//
//   performSegue(withIdentifier: "addDetails", sender: self)
//
//                let vc = segue.destination as? ImageDisplayViewController
//
//
//               // vc?.showMyPic = myPic
//                vc?.length = messageLabel.text!
//
//                stopRecording()
//                session.pause()
    }
    
    


    @IBAction func savePic(_ sender: Any) {
        let pic = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(pic, self, nil, nil)
      //  savePicButton.isHidden = true
     //   savePicToPhone.isHidden = true
 
        
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
    
    @IBAction func showAlertToSave(_ sender: Any) {
        
        let alert = UIAlertController(title: "Ready To Save", message: "Save your picture to show off", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
      
        
        alert.addAction(UIAlertAction(title: "Save to photos", style: .default, handler: {action in self.savePic(alert)}))
      
        alert.addAction(cancelAction)
      
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
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
        messageLabel.text = "Error occurred"
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
      //  resetButton.isHidden = true
        
        for line in lines {
            line.removeFromParentNode()
        }
        lines.removeAll()
        startMeasureButton.isHidden = false
        stopMeasureButton.isHidden = true
        outputImageView.isHidden = true
        photoTaken.isHidden = true
      //  photoTakenButton.isHidden = true
//        savePicButton.isHidden = true
//        savePicToPhone.isHidden = true
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
        
        startMeasureButton.isHidden = false
        stopMeasureButton.isHidden = true
        cameraButton.isHidden = false
    
//        savePicButton.isHidden = true
//        savePicToPhone.isHidden = true
//
        //pressToRecLabel.isHidden = false
        pressToStopRecLabel.isHidden = true
      //  stopButton.isHidden = true
       
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.startMeasureButton.layer.borderWidth = 3
        self.startMeasureButton.layer.cornerRadius = 5
        self.startMeasureButton.layer.masksToBounds = true
        
        self.stopMeasureButton.layer.borderWidth = 3
        self.stopMeasureButton.layer.cornerRadius = 5
        self.stopMeasureButton.layer.masksToBounds = true
        
       cameraButton.layer.borderWidth = 8
        cameraButton.layer.cornerRadius = cameraButton.frame.height/2
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

extension UILabel {
    func blink() {
        self.alpha = 0.0;
        UIView.animate(withDuration: 0.4, //Time duration you want,
            delay: 0.0,
            options: [.curveEaseInOut, .autoreverse, .repeat],
            animations: { [weak self] in self?.alpha = 1.0 },
            completion: { [weak self] _ in self?.alpha = 0.0 })
    }
}
