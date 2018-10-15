//
//  Line.swift
//  FishRuler
//
//  Created by user1 on 6/6/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import SceneKit
import ARKit

enum DistanceUnit {
    case centimeter
    case inch
    case meter
    
    var fator: Float {
        switch self {
        case .centimeter:
            return 100.0
        case .inch:
            return 39.3700787
        case .meter:
            return 1.0
        }
    }
    
    var unit: String {
        switch self {
        case .centimeter:
            return " cm"
        case .inch:
            return " inches"
        case .meter:
            return " m"
        }
    }
    
    var title: String {
        switch self {
        case .centimeter:
            return "Centimeters"
        case .inch:
            return "Inches"
        case .meter:
            return "Meters"
        }
    }
}

final class Line {
    fileprivate var color: UIColor = .white
    fileprivate var sideColor: UIColor = .blue
    
    
    
    fileprivate var startNode: SCNNode!
    fileprivate var endNode: SCNNode!
    fileprivate var text: SCNText!
    fileprivate var textNode: SCNNode!
    fileprivate var lineNode: SCNNode?
    
    fileprivate let sceneView: ARSCNView!
    fileprivate let startVector: SCNVector3!
    fileprivate let unit: DistanceUnit!
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: DistanceUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let dot = SCNBox(width: 0.5, height: 3, length: 0.5, chamferRadius: 0)
        
        let lineColor: UIColor = .white
        dot.firstMaterial?.diffuse.contents = lineColor
        dot.firstMaterial?.lightingModel = .constant
        dot.firstMaterial?.isDoubleSided = true
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(2/500.0, 2/500.0, 2/500.0)
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(2/500.0, 2/500.0, 2/500.0)
        
        
//       let textFront = SCNMaterial()
//        textFront.diffuse.contents = UIColor.black
//
//        let textSides = SCNMaterial()
//        textSides.diffuse.contents = UIColor.white
//
        
        text = SCNText(string: "", extrusionDepth: 2)
        text.font = UIFont(name: "Helvetica", size: 25)
        text.firstMaterial?.diffuse.contents = color
        text.alignmentMode  = convertFromCATextLayerAlignmentMode(CATextLayerAlignmentMode.center)
        text.truncationMode = convertFromCATextLayerTruncationMode(CATextLayerTruncationMode.middle)
        text.firstMaterial?.isDoubleSided = true
       // text.firstMaterial?.specular.contents = textFront
        //text.materials = [textSides, textFront]
        
      
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func update(to vector: SCNVector3) {
        
        lineNode?.removeFromParentNode()
        lineNode = startVector.line(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        text.string = distance(to: vector)
        textNode.position = SCNVector3((startVector.x+vector.x)/2.0, (startVector.y+vector.y)/2.0, (startVector.z+vector.z)/2.0)
        
        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
        }
    }
    
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%.2f%@", startVector.distance(from: vector) * unit.fator, unit.unit)
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerAlignmentMode(_ input: CATextLayerAlignmentMode) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCATextLayerTruncationMode(_ input: CATextLayerTruncationMode) -> String {
	return input.rawValue
}
