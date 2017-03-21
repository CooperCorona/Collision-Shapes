//
//  CollisionResult.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 3/20/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import Foundation
import UIKit
import CoronaStructures

public struct CollisionResult {
    
    /**
     First shape associated with the collision.
     If you call ```shape.collidesWith(otherShape)```
     then ```firstShape``` referes to ```shape```.
     */
    public let firstShape:CollisionShape
    
    /**
     First shape associated with the collision.
     If you call ```shape.collidesWith(otherShape)```
     then ```secondShape``` referes to ```otherShape```.
     */
    public let secondShape:CollisionShape
    
    /**
     Returns ```firstShape``` and ```secondShape``` as a tuple.
     Designed to work with legacy code, because the collision
     detection method used to return a tuple of the two
     shapes that collided. Thus, legacy applications that aren't
     ready to upgrade can just access the shapes property and
     continue on their way.
     */
    public var shapes:(CollisionShape, CollisionShape) {
        return (self.firstShape, self.secondShape)
    }
    /**
     The point at which the shapes collided. Not a perfect
     representation, as it should really be another shape
     defining the overlap, but that would be computationally
     expensive, so this is our compromise. If the collision
     is found because a point is inside another shape,
     ```collisionPoint``` is that point. Otherwise, it's
     the point at which the line segments of the two shapes collided.
     */
    public let collisionPoint:CGPoint
    
    internal func transform(by transform:SCMatrix4) -> CollisionResult {
        return CollisionResult(firstShape: self.firstShape, secondShape: self.secondShape, collisionPoint: transform * self.collisionPoint)
    }
    
}
