import UIKit
import OmniSwift

public enum CollisionBoxType {
    case HitBox
    case HurtBox
}

public protocol CollisionShape: GraphicsStateProtocol {
    
    var children:[CollisionShape] { get set }
    var boxType:CollisionBoxType { get }
    
    var points:[CGPoint] { get }
    var lines:[CollisionLineSegment] { get }
    
    func pointLiesInside(_: CGPoint) -> Bool
    
}

extension CollisionShape {
    
    public mutating func addChild(child:CollisionShape) {
        self.children.append(child)
    }
    
    public mutating func positionChildren() {
        for iii in 0..<self.children.count {
            self.children[iii].positionChildren()
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
    
    public func collidesWithShape(shape:CollisionShape) -> (CollisionShape, CollisionShape)? {
        return self.recursiveCollidesWith(SCMatrix4(), shape: shape, shapeTransform: SCMatrix4())
    }
    
    private func recursiveCollidesWith(selfTransform:SCMatrix4, shape:CollisionShape, shapeTransform:SCMatrix4) -> (CollisionShape, CollisionShape)? {
        
        let t1 = (self.graphicsState.modelMatrix() * selfTransform)
        let t2 = (shape.graphicsState.modelMatrix() * shapeTransform)
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
        
        for line in self.lines.map({ self.transformLine($0, by: t1, and: i2) }) {
            for sLine in shape.lines {
                if line.collidesWith(sLine) {
                    return (self, shape)
                }
            }
        }
        
        for sLine in shape.lines.map({ self.transformLine($0, by: t2, and: i1) }) {
            for line in self.lines {
                if sLine.collidesWith(line) {
                    return (self, shape)
                }
            }
        }
        
        let selfChildTransform = self.graphicsState.modelMatrix(false) * selfTransform
        let shapeChildTransform = shape.graphicsState.modelMatrix(false) * shapeTransform
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
    
    private func transformLine(line:CollisionLineSegment, by selfMatrix:SCMatrix4, and inverseMatrix:SCMatrix4) -> CollisionLineSegment {
        return CollisionLineSegment(firstPoint: inverseMatrix * (selfMatrix * line.firstPoint), secondPoint: inverseMatrix * (selfMatrix * line.secondPoint))
    }
    
    private func getTransformedLineSegments(selfMatrix:SCMatrix4, inverseMatrix:SCMatrix4) -> [CollisionLineSegment] {
        return self.lines.map() {
            return CollisionLineSegment(firstPoint: inverseMatrix * (selfMatrix * $0.firstPoint), secondPoint: inverseMatrix * (selfMatrix * $0.secondPoint))
        }
    }
    
}
