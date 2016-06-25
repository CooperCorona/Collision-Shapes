//
//  GLSCollisionShapeSprite.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 9/26/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import UIKit
import OmniSwift

class GLSCollisionShapeSprite: GLSSprite {

    // MARK: - Properties
    
    var shape:GLCollisionShape {
        didSet {
            self.regenerateVertices()
        }
    }
    
    // MARK: - Setup
    
    init(shape:GLCollisionShape) {
        self.shape = shape
        
        let frame = CGRect(points: shape.points)
        super.init(position: frame.center, size: frame.size, texture: CCTextureOrganizer.textureForString("White Tile"))
        
        self.regenerateVertices()
    }
    
    // MARK: - Logic
    
    func regenerateVertices() {
        let frame = CGRect(points: self.shape.points)
        let points  = self.getPointsFromShape(self.shape)
        
        self.contentSize = frame.size
        
        self.vertices = []
        for point in points {
            var vertex = UVertex()
            vertex.position = (point - frame.center).getGLTuple()
            self.vertices.append(vertex)
        }
        
        self.position = frame.center
        self.verticesAreDirty = true
    }
    
    func getPointsFromShape(shape:GLCollisionShape) -> [CGPoint] {
        var points = shape.getPoints()
        for case let child as GLCollisionShape in shape.children {
            points += self.getPointsFromShape(child)
        }
        return points
    }
    
}
