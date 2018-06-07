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

final class MeasureViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var meterImageView: UIImageView!
    @IBOutlet weak var resetImageView: UIImageView!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var outputImageView: UIImageView!
    
    
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
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetValues()
        isMeasuring = true
        targetImageView.image = UIImage(named: "targetGreen")
        targetLabel.isHidden = false
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
            resetButton.isHidden = false
            resetImageView.isHidden = false
            targetLabel.isHidden = true
            
        }
    }
    @IBAction func takePic(_ sender: Any) {
       outputImageView.image = sceneView.snapshot()
        photoTaken.isHidden = false
        photoTakenButton.isHidden = false
       
        
        
       
    func didTakePic(_image: UIImage)  {
        
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ImageDisplayViewController{
             let myPic = outputImageView.image
            let vc = segue.destination as? ImageDisplayViewController
            vc?.showMyPic = myPic!
           
            
    }
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
        resetButton.isHidden = true
        resetImageView.isHidden = true
        for line in lines {
            line.removeFromParentNode()
        }
        lines.removeAll()
    }
    
    
}

// MARK: - Privates

extension MeasureViewController {
    fileprivate func setupScene() {
        targetImageView.isHidden = true
        sceneView.delegate = self
        sceneView.session = session
        loadingView.startAnimating()
        meterImageView.isHidden = true
        messageLabel.text = "Looking for your fish..."
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 0
        resetButton.isHidden = true
        resetImageView.isHidden = true
        targetLabel.isHidden = true
        cameraButton.isHidden = false
        cameraButtonImage.isHidden = false
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
    }
    
    fileprivate func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
    }
    
    fileprivate func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
        targetImageView.isHidden = false
        meterImageView.isHidden = false
        
        if lines.isEmpty {
            messageLabel.text = "Place target at head, touch any location on screen and hold."
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
