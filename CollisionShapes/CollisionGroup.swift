//
//  CollisionGroup.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 10/2/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import UIKit
import OmniSwift

public class CollisionGroup: NSObject {

    // MARK: - Properties
    
    public private(set) var shape:CollisionShape {
        didSet {
            self.frame = shape.totalFrame
        }
    }
    public private(set) var frame = CGRect.zero
    
    public var center:CGPoint = CGPoint.zero {
        didSet {
            self.shape.translate(self.center - oldValue)
        }
    }
    public var flipH:Bool = false {
        didSet {
            if self.flipH != oldValue {
                self.shape.flipHorizontallyAbout(self.center.x)
            }
        }
    }
    public var flipV:Bool = false {
        didSet {
            if self.flipV != oldValue {
                self.shape.flipVerticallyAbout(self.center.y)
            }
        }
    }
    
    // MARK: - Setup
    
    public init(shape: CollisionShape) {
        self.shape = shape
        
        super.init()
    }
    
    public init(group:CollisionGroup) {
        self.shape  = group.shape
        self.frame  = group.frame
        self.center = group.center
        self.flipH  = group.flipH
        self.flipV  = group.flipV
        
        super.init()
    }
    
    // MARK: - Logic
    
    func collidesWith(group:CollisionGroup) -> (CollisionShape, CollisionShape)? {
        return self.shape.collidesWithShape(group.shape)
    }
    
}
