//
//  Ray.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 5/3/17.
//  Copyright © 2017 Cooper Knaak. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience
import CoronaStructures

public protocol RaycastResult {
    var ray:Ray { get }
    var collisionPoint:CGPoint { get }
    var length:CGFloat { get }
}

public struct SimpleRaycastResult: RaycastResult {
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
 
    public func reflect() -> Ray {
        /*
         *  The directions of the ray vector and the normal vector
         *  determine the proper angle-space to use ([-pi, pi] or [0, 2 pi]).
         *
         *  If you have a normal vector <-1, 0> and a ray vector
         *  <sqrt(3) / 2, 1 / 2>, you need to *subtract* the delta (pi / 6)
         *  from the normal vector.
         *
         *  If you have a normal vector <1, 0>
         *  and a ray vector <-sqrt(3) / 2, 1 / 2>, you need to *add* the
         *  delta (still pi / 6) to the normal vector.
         *
         *  In the first case, vectorAngle will be -5 pi / 6,
         *  but normalAngle will be pi, so the delta will be
         *  11 pi / 6. Because the absolute value of the delta
         *  and the angleToNormal are not the same (which they should
         *  be, because they measure the same thing), we know
         *  they're in different angle spaces, so we can just flip the
         *  sign of the delta.
         *
         *  In the second case, vectorAngle will be -pi / 6,
         *  and normalAngle will be 0. Delta will be pi / 6,
         *  which is the desired offset. Since the absolute value
         *  of delta is equal to the absolute value of angleToNormal,
         *  we know they're in the right angle space and can just use
         *  the sign of the delta.
         */
        let angleToNormal = abs(acos((-self.ray.vector).unit().dot(self.normal.unit())))
        let vectorAngle = (-self.ray.vector).angle()
        let normalAngle = self.normal.angle()
        let delta = (normalAngle - vectorAngle)
        let sign:CGFloat
        if abs(abs(delta) - abs(angleToNormal)) < Ray.epsilon {
            sign = delta.signOf()
        } else {
            sign = -delta.signOf()
        }
        return Ray(from: self.collisionPoint, direction: CGPoint(angle: normalAngle + sign * angleToNormal))
    }
    
}

public struct FullRaycastResult: RaycastResult {
    
    public let ray:Ray
    public let collisionPoint:CGPoint
    public let length:CGFloat
    public let normal:CGPoint?
    public let shape:CollisionShape?
    
    public init(ray:Ray, collisionPoint:CGPoint, length:CGFloat, normal:CGPoint?, shape:CollisionShape?) {
        self.ray = ray
        self.collisionPoint = collisionPoint
        self.length = length
        self.normal = normal
        self.shape = shape
    }

    public init(result:SimpleRaycastResult) {
        self.init(ray: result.ray, collisionPoint: result.collisionPoint, length: result.length, normal: result.normal, shape: result.shape)
    }
    
    public func clampLength(to maximumLength:CGFloat) -> FullRaycastResult {
        if self.length <= maximumLength {
            return self
        } else {
            let collisionPoint = self.ray.lineSegment.firstPoint + maximumLength * self.ray.vector
            return FullRaycastResult(ray: self.ray, collisionPoint: collisionPoint, length: maximumLength, normal: nil, shape: nil)
        }
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
    
    ///There's an error in the raycast where
    ///a raycast will reflect off a shape and
    ///then immediately collided with that shape
    ///again (with a length of about 2e-14). We
    ///need to make sure the dot product is not
    //just positive, it's positive to within a margin of error.
    fileprivate static let epsilon:CGFloat = 0.00000001
    
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
    
    public func raycast(shape:CollisionShape) -> SimpleRaycastResult? {
        return self.recursiveRaycast(shape: shape, shapeTransform: SCMatrix4())
    }
    
    private func recursiveRaycast(shape:CollisionShape, shapeTransform:SCMatrix4) -> SimpleRaycastResult? {
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
        
    private func collidesWith(line:LineSegment, from:CollisionShape) -> SimpleRaycastResult? {
        if self.lineSegment.isVertical && line.isVertical {
            guard abs(self.lineSegment.firstPoint.x - line.firstPoint.x) < Ray.epsilon else {
                return nil
            }
            let firstDelta = line.firstPoint - self.lineSegment.firstPoint
            let secondDelta = line.secondPoint - self.lineSegment.firstPoint
            let firstDot = firstDelta.y / self.vector.y
            let secondDot = secondDelta.y / self.vector.y
            let normal = CGPoint(x: 1.0, y: 0.0)

            if firstDot > Ray.epsilon && secondDot > Ray.epsilon {
                if firstDot < secondDot {
                    return SimpleRaycastResult(ray: self, collisionPoint: line.firstPoint, normal: self.adjust(normal: normal), shape: from)
                } else {
                    return SimpleRaycastResult(ray: self, collisionPoint: line.secondPoint, normal: self.adjust(normal: normal), shape: from)
                }
            } else if firstDot > Ray.epsilon {
                return SimpleRaycastResult(ray: self, collisionPoint: line.firstPoint, normal: self.adjust(normal: normal), shape: from)
            } else if secondDot > Ray.epsilon {
                return SimpleRaycastResult(ray: self, collisionPoint: line.secondPoint, normal: self.adjust(normal: normal), shape: from)
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
            if (point.y - self.lineSegment.firstPoint.y) / self.vector.y > Ray.epsilon {
                return SimpleRaycastResult(ray: self, collisionPoint: point, normal: self.adjust(normal: line.normal), shape: from)
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
                if (point - self.lineSegment.firstPoint).dot(self.vector) > Ray.epsilon {
                    return SimpleRaycastResult(ray: self, collisionPoint: point, normal: self.adjust(normal: line.normal), shape: from)
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
        guard (point - self.lineSegment.firstPoint).dot(self.vector) > Ray.epsilon else {
            return nil
        }
        if point.x.isBetween(line.frame.minX, and: line.frame.maxX) && point.y.isBetween(line.frame.minY, and: line.frame.maxY) {
            let length = point.distanceFrom(self.lineSegment.firstPoint)
            return SimpleRaycastResult(ray: self, collisionPoint: point, length: length, normal: self.adjust(normal: line.normal), shape: from)
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
    
    public func raycast(shapes:[CollisionShape]) -> SimpleRaycastResult? {
        return shapes.flatMap() { self.raycast(shape: $0) } .min() { $0.length < $1.length }
    }
    
    public func reflectingRaycast(maximumReflections:Int, shapes:[CollisionShape]) -> [SimpleRaycastResult] {
        var reflections = 0
        var raycasts:[SimpleRaycastResult] = []
        var ray:Ray = self
        while reflections <= maximumReflections {
            if let result = ray.raycast(shapes: shapes) {
                raycasts.append(result)
                ray = result.reflect()
            } else {
                break
            }
            reflections += 1
        }
        return raycasts
    }
    
    public func fullRaycast(maximumLength:CGFloat, maximumReflections:Int, shapes:[CollisionShape]) -> [FullRaycastResult] {
        let raycasts = self.reflectingRaycast(maximumReflections: maximumReflections, shapes: shapes)
        var remainingLength = maximumLength
        var clampedRaycasts:[FullRaycastResult] = []
        var i = -1
        for raycast in raycasts {
            i += 1
            clampedRaycasts.append(FullRaycastResult(result: raycast).clampLength(to: remainingLength))
            remainingLength -= raycast.length
            if remainingLength <= 0.0 {
                return clampedRaycasts
            }
        }
        //It's possible to have remaining length despite running
        //out of reflections, so we need to exit early in this case
        //(on top of violating the method's specification, it causes
        //the final raycast to ignore actual shapes, because it is
        //assumed that there can be no shapes left).
        guard raycasts.count < maximumReflections else {
            return clampedRaycasts
        }
        guard let last = raycasts.objectAtIndex(i) else {
            return clampedRaycasts
        }
        //It's possible there's some remaining length
        //left after the last simple raycast has succeeded.
        //If so, we know that there's no shape it will collide
        //with (or else there would be another SimpleRaycastResult),
        //so we just take the reflection and extend it to
        //the remaining length.
        let reflection = last.reflect()
        let end = reflection.lineSegment.firstPoint + remainingLength * reflection.vector
        clampedRaycasts.append(FullRaycastResult(ray: reflection, collisionPoint: end, length: remainingLength, normal: nil, shape: nil))
        return clampedRaycasts
    }
    
}
