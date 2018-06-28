//
//  SCNVector3.swift
//  FishRuler
//
//  Created by user1 on 6/6/18.
//  Copyright © 2018 campeez. All rights reserved.
//

import ARKit

extension SCNVector3 {
    static func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func distance(from vector: SCNVector3) -> Float {
        let distanceX = self.x - vector.x
        let distanceY = self.y - vector.y
        let distanceZ = self.z - vector.z
        
        return sqrtf((distanceX * distanceX) + (distanceY * distanceY) + (distanceZ * distanceZ))
    }
    
    func line(to vector: SCNVector3, color: UIColor = .white) -> SCNNode {
        
        let image = String("Fish Ruler")
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [self, vector])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        let geometry = SCNGeometry(sources: [source], elements: [element])
        geometry.firstMaterial?.diffuse.contents = image
        let node = SCNNode(geometry: geometry)
        
       
        return node
    }
}

extension SCNVector3: Equatable {
    public static func ==(lhs: SCNVector3, rhs: SCNVector3) -> Bool {
        return (lhs.x == rhs.x) && (lhs.y == rhs.y) && (lhs.z == rhs.z)
    }
}




