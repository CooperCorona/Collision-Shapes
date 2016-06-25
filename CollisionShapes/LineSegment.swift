//
//  LineSegment.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 6/25/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import UIKit

/**
 Defines a lightweight implementation of a line segment
 that is independant of any parent's space.
 */
public struct LineSegment {
    
    // MARK: - Properties
    
    public var firstPoint = CGPoint.zero
    public var secondPoint = CGPoint.zero
    public var isVertical:Bool {
        return self.firstPoint.x ~= self.secondPoint.x
    }
    public var slope:CGFloat? {
        if self.isVertical {
            return nil
        } else {
            return (self.secondPoint.y - self.firstPoint.y) / (self.secondPoint.x - self.firstPoint.x)
        }
    }
    public var yIntercept:CGFloat? {
        if let slope = self.slope {
            return (self.firstPoint.y - slope * self.firstPoint.x)
        }
        
        return nil
    }
    
    public var points:[CGPoint] {
        return [self.firstPoint, self.secondPoint]
    }
    
    public var frame:CGRect {
        let minX = min(self.firstPoint.x, self.secondPoint.x)
        let minY = min(self.firstPoint.y, self.secondPoint.y)
        let maxX = max(self.firstPoint.x, self.secondPoint.x)
        let maxY = max(self.firstPoint.y, self.secondPoint.y)
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    // MARK: - Setup
    
    public init(first:CGPoint, second:CGPoint) {
        self.firstPoint = first
        self.secondPoint = second
    }
    
    public static func linesBetweenPoints(points:[CGPoint]) -> [LineSegment] {
        var lines:[LineSegment] = []
        for (i, p) in points.enumerateSkipLast() {
            lines.append(LineSegment(first: p, second: points[i + 1]))
        }
        if let first = points.first, last = points.last where !(first ~= last) {
            lines.append(LineSegment(first: first, second: last))
        }
        return lines
    }
    
    // MARK: - Logic
    
    public func yAtX(x:CGFloat) -> CGFloat? {
        guard let slope = self.slope, yIntercept = self.yIntercept else {
            return nil
        }
        return slope * x + yIntercept
    }
    
    public func pointAtX(x:CGFloat) -> CGPoint? {
        guard let y = self.yAtX(x) else {
            return nil
        }
        return CGPoint(x: x, y: y)
    }
    
    public func pointLiesAbove(point:CGPoint) -> Bool {
        if let slope = self.slope, yIntercept = self.yIntercept {
            return point.y - slope * point.x > yIntercept
        } else {
            return point.x > self.firstPoint.x
        }
    }
    
    // MARK: - Collision
    
    public static func value(value:CGFloat, isInBetween lower:CGFloat, and higher:CGFloat) -> Bool {
        return (lower <= value && value <= higher) || (higher <= value && value <= lower)
    }
    
    public func collidesWith(line:LineSegment) -> Bool {
        
        if self.isVertical && line.isVertical {
            guard self.firstPoint.x ~= line.firstPoint.x else {
                return false
            }
            return LineSegment.value(line.firstPoint.y,  isInBetween: self.firstPoint.y, and: self.secondPoint.y)
                || LineSegment.value(line.secondPoint.y, isInBetween: self.firstPoint.y, and: self.secondPoint.y)
        } else if self.isVertical {
            if let point = line.pointAtX(self.firstPoint.x) {
                //                print("Checking Vertical: \(point)")
                //                return self.frame.contains(point) && line.frame.contains(point)
                return line.pointLiesAbove(self.firstPoint) != line.pointLiesAbove(self.secondPoint) && line.frame.contains(point)
            } else {
                return false
            }
        } else if line.isVertical {
            // This causes 'self' and 'line' to get flipped,
            // causing the previous if statement to get executed.
            return line.collidesWith(self)
        }
        
        
        guard let slope1 = self.slope, yIntercept1 = self.yIntercept, slope2 = line.slope, yIntercept2 = line.yIntercept where !(slope1 ~= slope2) else {
            return false
        }
        
        let x = (yIntercept1 - yIntercept2) / (slope2 - slope1)
        guard let point = self.pointAtX(x) else {
            return false
        }
        
        return self.frame.contains(point) && line.frame.contains(point)
    }
    
    public func pointLiesInside(point: CGPoint) -> Bool {
        
        guard self.frame.contains(point) else {
            return false
        }
        guard let selfPoint = self.pointAtX(point.x) else {
            return false
        }
        
        return selfPoint ~= point
    }
    
}