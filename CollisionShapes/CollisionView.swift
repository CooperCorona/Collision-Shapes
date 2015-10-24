//
//  CollisionView.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 9/27/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import UIKit
import OmniSwift

public class CollisionView: UIView {

    public var shape:CollisionShape = CollisionRectangle(size: CGSize(width: 64.0, height: 64.0)) {
        didSet {
            self.frame = self.shape.totalFrame
            self.setNeedsDisplay()
        }
    }
    public var fillColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var strokeColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        
        self.fillColor.setFill()
        self.strokeColor.setStroke()
        
        let paths = self.pathsFromShape(self.shape, origin: self.shape.totalFrame.origin)
        for path in paths {
            CGContextAddPath(context, path)
            CGContextFillPath(context)
            CGContextAddPath(context, path)
            CGContextStrokePath(context)
        }
        
        CGContextRestoreGState(context)
    }
    
    public func pathsFromShape(shape:CollisionShape, origin:CGPoint) -> [CGPath] {
        
        var paths:[CGPath] = []
        if shape.points.count > 0 {
            
            let path = CGPathCreateMutable()
            CGPathAddLines(path, nil, shape.points.map() { $0 - origin }, shape.points.count)
            CGPathCloseSubpath(path)
            paths.append(path)
        }
        
        for child in shape.children {
            paths += self.pathsFromShape(child, origin: origin)
        }
        
        return paths
    }
    
}
