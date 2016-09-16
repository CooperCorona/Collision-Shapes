
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience
import CoronaStructures

public enum CollisionBoxType {
    case hit
    case hurt
    case both
}

public protocol CollisionShape: TransformProtocol {
    
    var children:[CollisionShape] { get set }
    var boxType:CollisionBoxType { get }
    
    var points:[CGPoint] { get }
    
    func pointLiesInside(_: CGPoint) -> Bool
    
}

extension CollisionShape {
    
    public mutating func addChild(_ child:CollisionShape) {
        self.children.append(child)
    }
    
    public mutating func positionChildren() {
        for iii in 0..<self.children.count {
            self.children[iii].positionChildren()
        }
    }
    
    ///Returns true if at least one of the points in the array lies inside the shape.
    public func pointLiesInside(_ points:[CGPoint]) -> Bool {
        for point in points {
            if self.pointLiesInside(point) {
                return true
            }
        }
        
        return false
    }
    
    public func collidesWithShape(_ shape:CollisionShape) -> (CollisionShape, CollisionShape)? {
        return self.recursiveCollidesWith(SCMatrix4(), shape: shape, shapeTransform: SCMatrix4())
    }
    
    fileprivate func recursiveCollidesWith(_ selfTransform:SCMatrix4, shape:CollisionShape, shapeTransform:SCMatrix4) -> (CollisionShape, CollisionShape)? {
        
        let t1 = (self.transform.modelMatrix() * selfTransform)
        let t2 = (shape.transform.modelMatrix() * shapeTransform)
        let i1 = t1.inverse()
        let i2 = t2.inverse()
        
        let selfPoints  = self.points.map() { i2 * (t1 * $0) }
        let shapePoints = shape.points.map() { i1 * (t2 * $0) }
        for point in selfPoints {
            if shape.pointLiesInside(point) {
                return (self, shape)
            }
        }
        
        for point in shapePoints {
            if self.pointLiesInside(point) {
                return (self, shape)
            }
        }
        
        let selfLines  = LineSegment.linesBetweenPoints(self.points)
        let shapeLines = LineSegment.linesBetweenPoints(shape.points)
        for line in selfLines.map({ self.transformLine($0, by: t1, and: i2) }) {
            for sLine in shapeLines {
                if line.collidesWith(sLine) {
                    return (self, shape)
                }
            }
        }
        
        for sLine in shapeLines.map({ self.transformLine($0, by: t2, and: i1) }) {
            for line in selfLines {
                if sLine.collidesWith(line) {
                    return (self, shape)
                }
            }
        }
        
        let selfChildTransform = self.transform.modelMatrix(false) * selfTransform
        let shapeChildTransform = shape.transform.modelMatrix(false) * shapeTransform
        for child in shape.children {
            if let collisionInfo = self.recursiveCollidesWith(selfTransform, shape: child, shapeTransform: shapeChildTransform) {
                return collisionInfo
            } else {
                for sChild in self.children {
                    if let collisionInfo = sChild.recursiveCollidesWith(selfChildTransform, shape: child, shapeTransform: shapeChildTransform) {
                        return collisionInfo
                    }
                }
            }
        }
        
        for sChild in self.children {
            if let collisionInfo = sChild.recursiveCollidesWith(selfChildTransform, shape: shape, shapeTransform: shapeTransform) {
                return collisionInfo
            }
        }
        
        return nil
    }
    
    fileprivate func transformLine(_ line:LineSegment, by selfMatrix:SCMatrix4, and inverseMatrix:SCMatrix4) -> LineSegment {
        return LineSegment(first: inverseMatrix * (selfMatrix * line.firstPoint), second: inverseMatrix * (selfMatrix * line.secondPoint))
    }
    
}
