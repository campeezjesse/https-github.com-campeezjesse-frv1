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


final class MeasureViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!

    @IBOutlet weak var bottomPanel: UIView!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var outputImageView: UIImageView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var recVid: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pressToRecLabel: UILabel!
    @IBOutlet weak var pressToStopRecLabel: UILabel!
    

    @IBOutlet weak var savePicButton: UIButton!
    @IBOutlet weak var picSaved: UIImageView!

    
    @IBOutlet weak var instructionsText: UILabel!

    @IBOutlet weak var photoTakenButton: UIButton!
    @IBOutlet weak var photoTaken: UIImageView!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var cameraButtonImage: UIImageView!
    
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

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
      
        
        let touch: UITouch = touches.first as! UITouch
        
        if (touch.view == bottomPanel) {
         
        
        resetValues()
        isMeasuring = true
        targetImageView.image = UIImage(named: "targetGreen")
        targetLabel.isHidden = false
       
            bottomPanel.isHidden = true
            
            
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
            resetButton.isHidden = false
            bottomPanel.isHidden = true
            targetLabel.isHidden = true
            
           
       
        }
    }
    
    
    func startRecording() {
        
  
        if RPScreenRecorder.shared().isAvailable {
            
            RPScreenRecorder.shared().startRecording(handler: { (error) in
                if error == nil {
                } else {
                    print(error ?? "")
                    self.messageLabel.text = "Error recording occurred"
                }
            })
        }
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

    @IBAction func startVideoRec(_ sender: Any) {
        if isRecording {
            stopRecording()
            isRecording = false
        } else {
            startRecording()
            isRecording = true
            pressToRecLabel.isHidden = true
            pressToStopRecLabel.isHidden = false
            stopButton.isHidden = false
            recVid.isHidden = true
        }
    }
    
    
    @IBAction func stopRec(_ sender: Any) {
        stopRecording()
        pressToRecLabel.isHidden = false
        pressToStopRecLabel.isHidden = true
        stopButton.isHidden = true
        recVid.isHidden = false
    }
    
    @IBAction func takePic(_ sender: Any) {
       outputImageView.image = sceneView.snapshot()
        photoTaken.isHidden = false
        photoTakenButton.isHidden = false
        savePicButton.isHidden = false
        
        
       
    func didTakePic(_image: UIImage)  {
        
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageDisplayViewController{
             let myPic = sceneView.snapshot()
            let vc = segue.destination as? ImageDisplayViewController
         
            vc?.showMyPic = myPic
            vc?.length = messageLabel.text!
           stopRecording()
            
    }
}
    @IBAction func savePic(_ sender: Any) {
        let pic = sceneView.snapshot()
        UIImageWriteToSavedPhotosAlbum(pic, self, nil, nil)
        savePicButton.isHidden = true
  picSaved.isHidden = false
    }
    
    
    
    
    @IBAction func showPic(_ sender: Any) {
       
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
        let alertVC = UIAlertController(title: "Settings", message: "Please select distance unit options", preferredStyle: .actionSheet)
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
        instructionsText.isHidden = false
        bottomPanel.isHidden = false
        photoTaken.isHidden = true
        photoTakenButton.isHidden = true
        savePicButton.isHidden = true
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
        bottomPanel.isHidden = false
       // targetLabel.isHidden = true
        cameraButton.isHidden = false
        cameraButtonImage.isHidden = false
        //instructionsText.isHidden = false
        instructionsText.lineBreakMode = .byWordWrapping
        //instructionsText.isUserInteractionEnabled = true
        photoTakenButton.isHidden = true
        savePicButton.isHidden = true
        picSaved.isHidden = true
        pressToRecLabel.isHidden = false
        pressToStopRecLabel.isHidden = true
        stopButton.isHidden = true
       
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.bottomPanel.layer.borderWidth = 3
        self.bottomPanel.layer.cornerRadius = 5
        self.bottomPanel.layer.masksToBounds = true
    }
    
    fileprivate func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
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
