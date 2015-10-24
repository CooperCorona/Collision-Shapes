import UIKit
import OmniSwift

public struct CollisionTriangle: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    private var internalPoints:[CGPoint] = [CGPoint.zero, CGPoint.zero, CGPoint.zero]
    public var firstPoint:CGPoint {
        get {
            return self.internalPoints[0]
        }
        set {
            self.internalPoints[0] = newValue
        }
    }
    public var secondPoint:CGPoint {
        get {
            return self.internalPoints[1]
        }
        set {
            self.internalPoints[1] = newValue
        }
    }
    public var thirdPoint:CGPoint {
        get {
            return self.internalPoints[2]
        }
        set {
            self.internalPoints[2] = newValue
        }
    }
    public var center:CGPoint {
        get {
            return self.internalPoints.reduce(CGPoint.zero) { $0 + $1 } / 3.0
        }
        set {
            let delta = newValue - self.center
            for iii in self.internalPoints.range {
                self.internalPoints[iii] += delta
            }
            
            for iii in self.children.range {
                self.children[iii].setCenterOfParentRecursively(self.center)
            }
        }
    }
    public var lines:[CollisionLineSegment] {
        return [
            /*
            CollisionLineSegment(firstPoint: self.firstPoint, secondPoint: self.secondPoint),
            CollisionLineSegment(firstPoint: self.secondPoint, secondPoint: self.thirdPoint),
            CollisionLineSegment(firstPoint: self.thirdPoint, secondPoint: self.firstPoint)
            */
            CollisionLineSegment(firstPoint: self.points[0], secondPoint: self.points[1]),
            CollisionLineSegment(firstPoint: self.points[1], secondPoint: self.points[2]),
            CollisionLineSegment(firstPoint: self.points[2], secondPoint: self.points[0])
        ]
    }
    
    // MARK: - CollisionShape Properties
    
    public var frame:CGRect {
        var minX = self.firstPoint.x
        var maxX = self.firstPoint.x
        var minY = self.firstPoint.y
        var maxY = self.firstPoint.y
        for (_, point) in enumerate(self.internalPoints, range: 1..<3) {
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
    
    public var points:[CGPoint] { return self.internalPoints.map() { $0 + self.centerOfParent } }
    
    public var centerOfParent = CGPoint.zero
    public var boxType = CollisionBoxType.HitBox
    
    public var children:[CollisionShape] = []
    
    public var description:String { return "Triangle: \(self.firstPoint), \(self.secondPoint), \(self.thirdPoint)" }
    
    // MARK: - Setup
    
    public init() {
        
    }
    
    public init(firstPoint:CGPoint, secondPoint:CGPoint, thirdPoint:CGPoint) {
        self.internalPoints = [firstPoint, secondPoint, thirdPoint]
    }
    
    public init(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat, x3:CGFloat, y3:CGFloat) {
        self.firstPoint     = CGPoint(x: x1, y: y1)
        self.secondPoint    = CGPoint(x: x2, y: y2)
        self.thirdPoint     = CGPoint(x: x3, y: y3)
    }
    
    public init?(array:[CGFloat]) {
        guard array.count >= 6 else {
            return nil
        }
        
        self.firstPoint  = CGPoint(x: array[0], y: array[1])
        self.secondPoint = CGPoint(x: array[2], y: array[3])
        self.thirdPoint  = CGPoint(x: array[4], y: array[5])
    }
    
    // MARK: - Logic
    
    public func pointLiesInside(point:CGPoint) -> Bool {
        
        for line in self.lines {
            if line.pointLiesAbove(self.realCenter) != line.pointLiesAbove(point) {
                return false
            }
        }
        
        return true
    }
    
    public func collidesWith(triangle:CollisionTriangle) -> Bool {
        
        for point in self.points {
            if triangle.pointLiesInside(point) {
                return true
            }
        }
        
        for point in triangle.points {
            if self.pointLiesInside(point) {
                return true
            }
        }
        
        for sLine in self.lines {
            for tLine in triangle.lines {
                if sLine.collidesWith(tLine) {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: - CollisionShape Methods
    
    public mutating func translate(translation:CGPoint) {
        for iii in self.internalPoints.range {
            self.internalPoints[iii] += translation
        }
    }
    
    public mutating func flipHorizontallyAbout(x:CGFloat) {
        for iii in self.internalPoints.range {
            self.flip(&self.internalPoints[iii].x, about: x)
        }
        
        for iii in self.children.range {
            self.children[iii].flipHorizontallyAbout(0.0)
        }
    }
    
    public mutating func flipVerticallyAbout(y:CGFloat) {
        for iii in self.internalPoints.range {
            self.flip(&self.internalPoints[iii].y, about: y)
        }
        
        for iii in self.children.range {
            self.children[iii].flipVerticallyAbout(0.0)
        }
    }
    
}
