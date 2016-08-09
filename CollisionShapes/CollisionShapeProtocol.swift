import UIKit
import OmniSwift

public enum CollisionBoxType {
    case Hit
    case Hurt
    case Both
}

public protocol CollisionShape: GraphicsStateProtocol {
    
    var children:[CollisionShape] { get set }
    var boxType:CollisionBoxType { get }
    
    var points:[CGPoint] { get }
    
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
    
    private func transformLine(line:LineSegment, by selfMatrix:SCMatrix4, and inverseMatrix:SCMatrix4) -> LineSegment {
        return LineSegment(first: inverseMatrix * (selfMatrix * line.firstPoint), second: inverseMatrix * (selfMatrix * line.secondPoint))
    }
    
    public func generateSprite() -> GLSSprite {
        let sprite = GLSSprite(size: self.contentSize, texture: "White Tile")
        sprite.graphicsState = self.graphicsState
        if self.points.count > 0 {
            let center = self.points.reduce(CGPoint.zero) { $0 + $1 } / CGFloat(self.points.count)
            var vertices:[UVertex] = []
            var centerVertex = UVertex()
            centerVertex.position = center.getGLTuple()
            for (i, point) in self.points.enumerateSkipLast() {
                var v1 = UVertex()
                var v2 = UVertex()
                v1.position = point.getGLTuple()
                v2.position = self.points[i + 1].getGLTuple()
                vertices += [centerVertex, v1, v2]
            }
            var v1 = UVertex()
            var v2 = UVertex()
            v1.position ??= self.points.last?.getGLTuple()
            v2.position ??= self.points.first?.getGLTuple()
            vertices += [centerVertex, v1, v2]
            sprite.vertices = vertices
        }
        for child in self.children {
            let childSprite = child.generateSprite()
            sprite.addChild(childSprite)
        }
        return sprite
    }
    
}
