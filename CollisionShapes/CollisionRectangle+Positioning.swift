//
//  CollisionRectangle+Positioning.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 11/25/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import UIKit
import OmniSwift

extension CollisionRectangle {
    
    public var bottomLeft:CGPoint {
        get {
            return self.center - self.size.center
        }
        set {
            self.center = newValue + self.size.center
        }
    }
    
    public var bottomRight:CGPoint {
        get {
            return CGPoint(x: self.center.x + self.size.width / 2.0, y: self.center.y - self.size.height / 2.0)
        }
        set {
            self.center = CGPoint(x: newValue.x - self.size.width / 2.0, y: newValue.y + self.size.height / 2.0)
        }
    }
    
    public var topRight:CGPoint {
        get {
            return CGPoint(x: self.center.x + self.size.width / 2.0, y: self.center.y + self.size.height / 2.0)
        }
        set {
            self.center = CGPoint(x: newValue.x - self.size.width / 2.0, y: newValue.y - self.size.height / 2.0)
        }
    }
    
    public var topLeft:CGPoint {
        get {
            return CGPoint(x: self.center.x - self.size.width / 2.0, y: self.center.y + self.size.height / 2.0)
        }
        set {
            self.center = CGPoint(x: newValue.x + self.size.width / 2.0, y: newValue.y - self.size.height / 2.0)
        }
    }
    
}