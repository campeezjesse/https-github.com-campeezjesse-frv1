//
//  mesureViewController.swift
//  FishRluer
//
//  Created by user1 on 5/29/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class mesureViewController: UIViewController, ARSCNViewDelegate{
    var nodes: [SphereNode] = []
    
    @IBOutlet weak var resetButton: UIButton!
    
   
    lazy var sceneView: ARSCNView = {
        let view = ARSCNView(frame: CGRect.zero)
        view.delegate = self
        view.autoenablesDefaultLighting = true
        view.antialiasingMode = SCNAntialiasingMode.multisampling4X
        return view
    }()
    
  
   
    
    lazy var infoLabel: UILabel = {
        
    
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        label.textAlignment = .center
        label.backgroundColor = .gray
       
       // let date = Date()
       // let formater = DateFormatter()
      //  formater.dateFormat = "dd/mm/yyyy"
      //  let result = formater.string(from: date)
      //  label.text = result
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        view.addSubview(infoLabel)

        
         sceneView.delegate = self
        
        
       
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
        
      
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneView.frame = view.bounds
        infoLabel.frame = CGRect(x: 0, y: 16, width: view.bounds.width, height: 64)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
   
        // MARK: ARSCNViewDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        var status = "Loading..."
        switch camera.trackingState {
        case ARCamera.TrackingState.notAvailable:
            status = "Not available"
        case ARCamera.TrackingState.limited(_):
            status = "Analyzing..."
        case ARCamera.TrackingState.normal:
            status = "Ready"
        }
        infoLabel.text = status
    }

    // MARK: Gesture handlers
    @objc func handleTap(sender: UITapGestureRecognizer) {
        
        let tapLocation = sender.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .featurePoint)
        if let result = hitTestResults.first {
            let position = SCNVector3.positionFrom(matrix: result.worldTransform)
            
            let sphere = SphereNode(position: position)

       
            sceneView.scene.rootNode.addChildNode(sphere)
            
            let tail = nodes.last
            
            nodes.append(sphere)
            
            if tail != nil {
                let distance = tail!.position.distance(to: sphere.position)
                infoLabel.text = String(format: "Size: %.2f inches", distance)
                
                if nodes.count > 2 {
                    
                    nodes.removeAll()
                    
                }
            }else{
                nodes.append(sphere)
                
            }
            }
        }
    }




    extension SCNVector3 {
        func distance(to destination: SCNVector3) -> CGFloat {
            let inches: Float = 39.3701
            let dx = destination.x - x
            let dy = destination.y - y
            let dz = destination.z - z
            let meters = sqrt(dx*dx + dy*dy + dz*dz)
            return CGFloat(meters * inches)
        }
    
    static func positionFrom(matrix: matrix_float4x4) -> SCNVector3 {
        let column = matrix.columns.3
        return SCNVector3(column.x, column.y, column.z)
    }
}
