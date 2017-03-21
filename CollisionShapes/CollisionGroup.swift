//
//  CollisionGroup.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 8/4/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience
import CoronaStructures

/**
 CollisionGroup conforms to the CollisionShapeProtocol but does not
 define any shape; rather, its point and line arrays are empty, so
 no expensive calculations are performed (and there's no danger of
 a single point colliding with something). Use it to group shapes
 together.
 */
public struct CollisionGroup: CollisionShape, ExpressibleByArrayLiteral {

    public typealias Element = CollisionShape
    
    public var transform = Transform()
    public var children:[CollisionShape] = [] {
        didSet {
            self.axisAlignedCollisionFrame = self.calculateCollisionFrame()
        }
    }
    public var boxType = CollisionBoxType.both
    
    public var points:[CGPoint] = []
    
    public var log = false
    fileprivate var axisAlignedCollisionFrame = CGRect.zero
    public var collisionFrame:CGRect {
        let matrix = self.transform.modelMatrix()
        let points = [
            self.axisAlignedCollisionFrame.bottomLeftGL,
            self.axisAlignedCollisionFrame.bottomRightGL,
            self.axisAlignedCollisionFrame.topLeftGL,
            self.axisAlignedCollisionFrame.topRightGL,
        ].map() { matrix * $0 }
        var minX = points[0].x
        var maxX = points[0].x
        var minY = points[0].y
        var maxY = points[0].y
        for (_, point) in points.enumerateSkipFirst() {
            if point.x < minX {
                minX = point.x
            } else if point.x > maxX {
                maxX = point.x
            }
            if point.y < minY {
                minY = point.y
            } else if point.y > maxY {
                maxY = point.y
            }
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    public init(children:[CollisionShape]) {
        self.children = children
        self.axisAlignedCollisionFrame = self.calculateCollisionFrame()
    }
    
    public init(arrayLiteral elements:CollisionShape...) {
        self.children = elements
        self.axisAlignedCollisionFrame = self.calculateCollisionFrame()
    }
    
    ///Point cannot lie inside it because a CollisionGroup defines no shape.
    public func pointLiesInside(_: CGPoint) -> Bool {
        return false
    }

    fileprivate func calculateCollisionFrame() -> CGRect {
        guard let firstChild = self.children.first else {
            return CGRect.zero
        }
        guard var firstPoint = firstChild.points.first else {
            return CGRect.zero
        }
        firstPoint = firstChild.transform.modelMatrix() * firstPoint
        var minX:CGFloat = firstPoint.x
        var maxX:CGFloat = firstPoint.x
        var minY:CGFloat = firstPoint.y
        var maxY:CGFloat = firstPoint.y
        let identity = SCMatrix4()
        for child in self.children {
            self.collisionFrame(child, matrix: identity, minX: &minX, minY: &minY, maxX: &maxX, maxY: &maxY)
        }
        if log {
            print(firstChild)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    fileprivate func collisionFrame(_ shape:CollisionShape, matrix:SCMatrix4, minX:inout CGFloat, minY:inout CGFloat, maxX:inout CGFloat, maxY:inout CGFloat) {
        let model = shape.transform.modelMatrix() * matrix
        for point in shape.points.map({ model * $0 }) {
            if point.x < minX {
                minX = point.x
            } else if point.x > maxX {
                maxX = point.x
            }
            if point.y < minY {
                minY = point.y
            } else if point.y > maxY {
                maxY = point.y
            }
        }
        let childModel = shape.transform.modelMatrix(false) * matrix
        for child in shape.children {
            self.collisionFrame(child, matrix: childModel, minX: &minX, minY: &minY, maxX: &maxX, maxY: &maxY)
        }
    }
    
}
