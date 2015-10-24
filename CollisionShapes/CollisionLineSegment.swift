import UIKit
import OmniSwift

public struct CollisionLineSegment: CollisionShape, CustomStringConvertible {
    
    // MARK: - Propertise
    
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
    
    // MARK: - CollisionShape Properties
    
    public var center:CGPoint {
        get {
            return (self.firstPoint + self.secondPoint) / 2.0
        }
        set {
            self.translate(newValue - self.center)
            for iii in self.children.range {
                self.children[iii].setCenterOfParentRecursively(self.center)
            }
        }
    }
    public var frame:CGRect { return CGRect(points: [self.firstPoint, self.secondPoint]) }
    public var children:[CollisionShape] = []
    public var boxType = CollisionBoxType.HitBox
    public var centerOfParent = CGPoint.zero
    
    public var lines:[CollisionLineSegment] { return [self] }
    public var points:[CGPoint] { return [self.firstPoint + self.centerOfParent, self.secondPoint + self.centerOfParent] }
    
    public var description:String { return "LineSegment (\(self.firstPoint), \(self.secondPoint))" }
    
    // MARK: - Setup
    
    public init(firstPoint:CGPoint, secondPoint:CGPoint) {
        self.firstPoint  = firstPoint
        self.secondPoint = secondPoint
    }
    
    public init(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat) {
        self.firstPoint     = CGPoint(x: x1, y: y1)
        self.secondPoint    = CGPoint(x: x2, y: y2)
    }
    
    public init?(array:[CGFloat]) {
        guard array.count >= 4 else {
            return nil
        }
        
        self.firstPoint  = CGPoint(x: array[0], y: array[1])
        self.secondPoint = CGPoint(x: array[2], y: array[3])
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
    
    public func collidesWith(line:CollisionLineSegment) -> Bool {
        
        if self.isVertical && line.isVertical {
            guard self.firstPoint.x ~= line.firstPoint.x else { return false }
            return  CSSShape.inBetween(lower: self.firstPoint.y, higher: self.secondPoint.y, value: line.firstPoint.y) ||
                CSSShape.inBetween(lower: self.firstPoint.y, higher: self.secondPoint.y, value: line.secondPoint.y)
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
    
    public func collidesWith(rect:CollisionRectangle) -> Bool {
        return self.collidesWithGenericShape(rect)
    }
    
    public func collidesWith(triangle:CollisionTriangle) -> Bool {
        return self.collidesWithGenericShape(triangle)
    }
    
    public func collidesWith(ellipse:CollisionEllipse) -> Bool {
        
        if ellipse.pointLiesInside(self.points) {
            return true
        }
        
        for line in ellipse.lines {
            if self.collidesWith(line) {
                return true
            }
        }
        
        return false
    }
    
    public func collidesWithGenericShape(shape:CollisionShape) -> Bool {
        
        if shape.pointLiesInside(self.firstPoint) || shape.pointLiesInside(self.secondPoint) {
            return true
        }
        
        for line in shape.lines {
            if self.collidesWith(line) {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - CollisionShape Methods
    
    public func pointLiesInside(point: CGPoint) -> Bool {
        
        guard self.frame.contains(point) else {
            return false
        }
        guard let selfPoint = self.pointAtX(point.x) else {
            return false
        }
        
        return selfPoint ~= point
    }
    
    public mutating func translate(translation:CGPoint) {
        self.firstPoint  += translation
        self.secondPoint += translation
    }
    
    public mutating func flipHorizontallyAbout(x:CGFloat) {
        self.flip(&self.firstPoint.x,  about: x)
        self.flip(&self.secondPoint.x, about: x)
        
        for iii in self.children.range {
            self.children[iii].flipHorizontallyAbout(0.0)
        }
    }
    
    public mutating func flipVerticallyAbout(y:CGFloat) {
        self.flip(&self.firstPoint.y,  about: y)
        self.flip(&self.secondPoint.y, about: y)
        
        for iii in self.children.range {
            self.children[iii].flipVerticallyAbout(0.0)
        }
    }
    
}