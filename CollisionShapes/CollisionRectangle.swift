import UIKit
import OmniSwift

public struct CollisionRectangle: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    public var center  = CGPoint.zero {
        didSet {
            self.centerChanged()
        }
    }
    public var size    = CGSize.zero
    
    public var minX:CGFloat { return self.realCenter.x - self.size.width / 2.0 }
    public var maxX:CGFloat { return self.realCenter.x + self.size.width / 2.0 }
    public var minY:CGFloat { return self.realCenter.y - self.size.height / 2.0 }
    public var maxY:CGFloat { return self.realCenter.y + self.size.height / 2.0 }
    
    // MARK: - CollisionShape Properties
    
    public var centerOfParent = CGPoint.zero
    public var frame:CGRect { return CGRect(center: self.center, size: self.size) }
    public var children:[CollisionShape] = []
    public var boxType = CollisionBoxType.HitBox
    
    public var description:String { return "CollisionRectangle (\(self.center), \(self.size))" }
    
    public var points:[CGPoint] {
        return [
            CGPoint(x: self.minX, y: self.minY),
            CGPoint(x: self.maxX, y: self.minY),
            CGPoint(x: self.maxX, y: self.maxY),
            CGPoint(x: self.minX, y: self.maxY)
        ]
    }
    public var lines:[CollisionLineSegment] {
        return [
            CollisionLineSegment(firstPoint: CGPoint(x: self.minX, y: self.minY), secondPoint: CGPoint(x: self.minX, y: self.maxY)),
            CollisionLineSegment(firstPoint: CGPoint(x: self.minX, y: self.maxY), secondPoint: CGPoint(x: self.maxX, y: self.maxY)),
            CollisionLineSegment(firstPoint: CGPoint(x: self.maxX, y: self.maxY), secondPoint: CGPoint(x: self.maxX, y: self.minY)),
            CollisionLineSegment(firstPoint: CGPoint(x: self.maxX, y: self.minY), secondPoint: CGPoint(x: self.minX, y: self.minY))
        ]
    }
    
    // MARK: - Setup
    
    public init() {
        
    }
    
    public init(size:CGSize) {
        self.size = size
    }
    
    public init(center:CGPoint, size:CGSize) {
        self.center = center
        self.size   = size
    }
    
    // MARK: - Logic
    
    public func pointLiesInside(point: CGPoint) -> Bool {
        return self.minX <= point.x && point.x <= self.maxX
            && self.minY <= point.y && point.y <= self.maxY
    }
    
    // MARK: - CollisionShape Logic
    
    public mutating func translate(translation: CGPoint) {
        self.center += translation
    }
    
    public mutating func flipHorizontallyAbout(x: CGFloat) {
        
        self.flip(&self.center.x, about: x)
        
        for iii in self.children.range {
            self.children[iii].flipHorizontallyAbout(0.0)
        }
        
    }
    
    public mutating func flipVerticallyAbout(y: CGFloat) {
        
        self.flip(&self.center.y, about: y)
        
        for iii in self.children.range {
            self.children[iii].flipVerticallyAbout(0.0)
        }
    }
    
    // MARK: - Collision
    
    public func collidesWith(rect:CollisionRectangle) -> Bool {
        return !(self.minX > rect.maxX
              || self.maxX < rect.minX
              || self.minY > rect.maxY
              || self.maxY < rect.minY)
    }
    
    public func collidesWith(triangle:CollisionTriangle) -> Bool {
        
        if self.pointLiesInside(triangle.points) {
            return true
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
    
    public func collidesWith(ellipse:CollisionEllipse) -> Bool {
        
        if ellipse.pointLiesInside(self.points) {
            return true
        }
        
        for sLine in self.lines {
            for eLine in ellipse.lines {
                if sLine.collidesWith(eLine) {
                    return true
                }
            }
        }
        
        return false
    }
    
}