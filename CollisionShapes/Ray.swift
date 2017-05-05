//
//  Ray.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 5/3/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import Foundation
import CoronaConvenience
import CoronaStructures

public struct RaycastResult {
    public let ray:Ray
    public let collisionPoint:CGPoint
    public let length:CGFloat
    public let normal:CGPoint
    public let shape:CollisionShape
    
    public init(ray:Ray, collisionPoint:CGPoint, length:CGFloat, normal:CGPoint, shape:CollisionShape) {
        self.ray = ray
        self.collisionPoint = collisionPoint
        self.length = length
        self.normal = normal
        self.shape = shape
    }
    
    public init(ray:Ray, collisionPoint:CGPoint, normal:CGPoint, shape:CollisionShape) {
        let length = ray.lineSegment.firstPoint.distanceFrom(collisionPoint)
        self.init(ray: ray, collisionPoint: collisionPoint, length: length, normal: normal, shape: shape)
    }
}

/**
 Defines a ray, which is a line with
 a start point but not end point (it
 extends to infinity). Not actually a
 CollisionShape because it doesn't
 define a line (since it's infinite).
 Used exclusively for raycasting.
 */
public struct Ray {
    
    public let lineSegment:LineSegment
    public let vector:CGPoint
    
    public init(from:CGPoint, through:CGPoint) {
        self.lineSegment = LineSegment(first: from, second: through)
        self.vector = (through - from).unit()
    }
    
    public init(from:CGPoint, direction:CGPoint) {
        self.vector = direction.unit()
        self.lineSegment = LineSegment(first: from, second: from + vector)
    }
    
    public func raycast(shape:CollisionShape) -> RaycastResult? {
        return self.recursiveRaycast(shape: shape, shapeTransform: SCMatrix4())
    }
    
    private func recursiveRaycast(shape:CollisionShape, shapeTransform:SCMatrix4) -> RaycastResult? {
        let subTransform = shape.transform.modelMatrix() * shapeTransform
        let transformedLines = LineSegment.linesBetweenPoints(shape.points).map() { LineSegment(first: subTransform * $0.firstPoint, second: subTransform * $0.secondPoint) }
        let collision = transformedLines.flatMap() { self.collidesWith(line: $0, from: shape) } .min() { $0.length < $1.length }
        let childTransform = shape.transform.modelMatrix(false) * shapeTransform
        let childCollision = shape.children.flatMap() { self.recursiveRaycast(shape: $0, shapeTransform: childTransform) } .min() { $0.length < $1.length }
        if let col1 = collision, let col2 = childCollision {
            if col1.length < col2.length {
                return col1
            } else {
                return col2
            }
        }
        //If at least of them is nil, then we use the
        //nil coalescing operator to choose one of them.
        //If the first one exists, then the second doesn't,
        //so we return that. Otherwise, the nil coalescing operator
        //returns the second one (which we know to exist).
        return collision ?? childCollision
    }
        
    private func collidesWith(line:LineSegment, from:CollisionShape) -> RaycastResult? {
        if self.lineSegment.isVertical && line.isVertical {
            let firstDelta = line.firstPoint - self.lineSegment.firstPoint
            let secondDelta = line.secondPoint - self.lineSegment.firstPoint
            let firstDot = firstDelta.y / self.vector.y
            let secondDot = secondDelta.y / self.vector.y
            let normal = CGPoint(x: 1.0, y: 0.0)
//            return firstDelta.y / self.vector.y > 0.0 || secondDelta.y / self.vector.y > 0.0
            if firstDot > 0.0 && secondDot > 0.0 {
                if firstDot < secondDot {
                    return RaycastResult(ray: self, collisionPoint: line.firstPoint, normal: self.adjust(normal: normal), shape: from)
                } else {
                    return RaycastResult(ray: self, collisionPoint: line.secondPoint, normal: self.adjust(normal: normal), shape: from)
                }
            } else if firstDot > 0.0 {
                return RaycastResult(ray: self, collisionPoint: line.firstPoint, normal: self.adjust(normal: normal), shape: from)
            } else if secondDot > 0.0 {
                return RaycastResult(ray: self, collisionPoint: line.secondPoint, normal: self.adjust(normal: normal), shape: from)
            }
            return nil
        } else if self.lineSegment.isVertical {
            guard self.lineSegment.firstPoint.x.isBetween(line.firstPoint.x, and: line.secondPoint.x) else {
                return nil
            }
            guard let point = line.pointAtX(self.lineSegment.firstPoint.x) else {
                //This won't actually ever happen, but we need to unwrap
                //the optional somehow.
                return nil
            }
            if (point.y - self.lineSegment.firstPoint.y) / self.vector.y > 0.0 {
                return RaycastResult(ray: self, collisionPoint: point, normal: self.adjust(normal: line.normal), shape: from)
            } else {
                return nil
            }
        } else if line.isVertical {
            guard let y = self.lineSegment.yAtX(line.firstPoint.x) else {
                //Once again, self.lineSegment can never be vertical in this
                //if case, so this return nil won't ever execute.
                return nil
            }
            if y.isBetween(line.firstPoint.y, and: line.secondPoint.y) {
                let point = CGPoint(x: line.firstPoint.x, y: y)
                if (point - self.lineSegment.firstPoint).dot(self.vector) > 0.0 {
                    return RaycastResult(ray: self, collisionPoint: point, normal: self.adjust(normal: line.normal), shape: from)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        guard let selfSlope = self.lineSegment.slope, let lineSlope = line.slope, let selfIntercept = self.lineSegment.yIntercept, let lineIntercept = line.yIntercept else {
            //Again, the slopes are guaranteed to exist at this point.
            return nil
        }
        //y = m_1x + b_1 = m_2x + b_2
        //(m_1 - m_2) x = (b_2 - b_1)
        //x = (b_2 - b_1) / (m_1 - m_2)
        let x = (selfIntercept - lineIntercept) / (lineSlope - selfSlope)
        guard let point = self.lineSegment.pointAtX(x) else {
            return nil
        }
        //Must be in same direction as ray.
        guard (point - self.lineSegment.firstPoint).dot(self.vector) > 0.0 else {
            return nil
        }
        if point.x.isBetween(line.frame.minX, and: line.frame.maxX) && point.y.isBetween(line.frame.minY, and: line.frame.maxY) {
            let length = point.distanceFrom(self.lineSegment.firstPoint)
            return RaycastResult(ray: self, collisionPoint: point, length: length, normal: self.adjust(normal: line.normal), shape: from)
        } else {
            return nil
        }
    }
    
    ///There are actual 2 normal vectors for each line.
    ///The correct one is based on which direction the
    ///ray is going (and thus which direction it can
    ///collide with the line on).
    private func adjust(normal:CGPoint) -> CGPoint {
        //If the dot product is positive, it means
        //the ray and the normal are pointing in
        //the same direction, which means the normal
        //is somehow going to the other side of the
        //line. That means it must be the wrong normal.
        if normal.dot(self.vector) > 0.0 {
            return -normal
        } else {
            return normal
        }
    }
    
    public func raycast(shapes:[CollisionShape]) -> RaycastResult? {
        return shapes.flatMap() { self.raycast(shape: $0) } .min() { $0.length < $1.length }
    }
    
}
