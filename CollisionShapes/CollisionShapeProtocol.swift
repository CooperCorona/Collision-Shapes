import UIKit
import OmniSwift

public enum CollisionBoxType {
    case HitBox
    case HurtBox
}

public protocol CollisionShape {
    
    var center:CGPoint { get }
    var children:[CollisionShape] { get set }
    var frame:CGRect { get }
    var boxType:CollisionBoxType { get }
    var centerOfParent:CGPoint { get set }
    
    var points:[CGPoint] { get }
    var lines:[CollisionLineSegment] { get }
    
    func pointLiesInside(_: CGPoint) -> Bool
    
    mutating func translate(_: CGPoint)
    mutating func flipHorizontallyAbout(_: CGFloat)
    mutating func flipVerticallyAbout(_: CGFloat)
    
}

extension CollisionShape {
    
    ///The center of the shape including the center of the parent.
    public var realCenter:CGPoint { return self.center + self.centerOfParent }
    ///The frame encompassing the shape and all its children.
    public var totalFrame:CGRect {
        /*
        func getFrames(shape:CollisionShape) -> [CGRect] {
            var frames = [shape.frame + shape.centerOfParent]
            for curShape in shape.children {
                frames += getFrames(curShape)
            }
            return frames
        }
        
        return CGRect(rects: getFrames(self))
        */
        let rects = self.children.recursiveReduce(self) { $0.children }
        return CGRect(rects: rects.map() { $0.frame + $0.centerOfParent })
    }
    
    public mutating func addChild(var child:CollisionShape) {
        child.setCenterOfParentRecursively(self.realCenter)
        self.children.append(child)
    }
    
    public mutating func positionChildren() {
        for iii in 0..<self.children.count {
            self.children[iii].positionChildren()
        }
    }
    
    public mutating func flipAbout(point:CGPoint) {
        self.flipHorizontallyAbout(point.x)
        self.flipVerticallyAbout(point.y)
    }
    
    public mutating func setCenterOfParentRecursively(point:CGPoint) {
        self.centerOfParent = point
        for iii in self.children.range {
            self.children[iii].setCenterOfParentRecursively(point + self.center)
        }
    }
    
    ///Returns true if at least one of the points in the array lies inside the shape.
    public func pointLiesInside(points:[CGPoint]) -> Bool {
        for point in points {
            if self.pointLiesInside(point) {
                return true
            }
        }
        
        return false
    }
    
    public func flip(inout value:CGFloat, about u:CGFloat) {
        value = 2.0 * u - value
    }
    
    public func collidesWithShape(shape:CollisionShape, depth:Int = 0) -> (CollisionShape, CollisionShape)? {
        
        if !self.totalFrame.intersects(shape.totalFrame) {
            return nil
        }
        
        for point in self.points {
            if shape.pointLiesInside(point) {
                return (self, shape)
            }
        }
        
        for point in shape.points {
            if self.pointLiesInside(point) {
                return (self, shape)
            }
        }
        
        for line in self.lines {
            for sLine in shape.lines {
                if line.collidesWith(sLine) {
                    return (self, shape)
                }
            }
        }
        
        for child in shape.children {
            if let collisionInfo = self.collidesWithShape(child) {
                return collisionInfo
            } else {
                for sChild in self.children {
                    if let collisionInfo = child.collidesWithShape(sChild, depth: depth + 1) {
                        return collisionInfo
                    }
                }
            }
        }
        
        for sChild in self.children {
            if let collisionInfo = sChild.collidesWithShape(shape) {
                return collisionInfo
            }
        }
        
        return nil
    }
    
    public mutating func centerChanged() {
        for iii in self.children.range {
            self.children[iii].setCenterOfParentRecursively(self.center)
        }
    }
    
}
