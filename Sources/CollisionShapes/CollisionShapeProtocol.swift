
import CoronaMath

public enum CollisionBoxType {
    case hit
    case hurt
    case both
}

public protocol CollisionShape: Transformable {
    
    var children:[CollisionShape] { get set }
    var boxType:CollisionBoxType { get }
    
    var points:[Point] { get }
    
    func pointLiesInside(_: Point) -> Bool
    
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
    public func pointLiesInside(_ points:[Point]) -> Bool {
        for point in points {
            if self.pointLiesInside(point) {
                return true
            }
        }
        
        return false
    }
    
    public func collidesWithShape(_ shape:CollisionShape) -> CollisionResult? {
        return self.recursiveCollidesWith(selfTransform: Matrix3.identity, shape: shape, shapeTransform: Matrix3.identity)
    }
    
    fileprivate func recursiveCollidesWith(selfTransform:Matrix3, shape:CollisionShape, shapeTransform:Matrix3) -> CollisionResult? {
        
        let t1 = (self.transform.modelMatrix() * selfTransform)
        let t2 = (shape.transform.modelMatrix() * shapeTransform)
        let i1 = t1.inverse()
        let i2 = t2.inverse()
        
        //The matrix times point multiplication '*' is being considered ambiguous for
        //some reason, but casting them to their values fixes this.
        let selfPoints  = self.points.map() { (point:Point) in i2 * (t1 * point) }
        let shapePoints = shape.points.map() { (point:Point) in i1 * (t2 * point) }
        for point in selfPoints {
            if shape.pointLiesInside(point) {
                return CollisionResult(firstShape: self, secondShape: shape, collisionPoint: point).transform(by: t2)
            }
        }
        
        for point in shapePoints {
            if self.pointLiesInside(point) {
                return CollisionResult(firstShape: self, secondShape: shape, collisionPoint: point).transform(by: t1)
            }
        }
        
        let selfLines  = LineSegment.linesBetweenPoints(self.points)
        let shapeLines = LineSegment.linesBetweenPoints(shape.points)
        for line in selfLines.map({ self.transform(line: $0, by: t1, and: i2) }) {
            for sLine in shapeLines {
                if let point = line.collidesWith(sLine) {
                    return CollisionResult(firstShape: self, secondShape: shape, collisionPoint: point).transform(by: t2)
                }
            }
        }
        
        for sLine in shapeLines.map({ self.transform(line: $0, by: t2, and: i1) }) {
            for line in selfLines {
                if let point = sLine.collidesWith(line) {
                    return CollisionResult(firstShape: self, secondShape: shape, collisionPoint: point).transform(by: t1)
                }
            }
        }
        
        let selfChildTransform = self.transform.modelMatrix(false) * selfTransform
        let shapeChildTransform = shape.transform.modelMatrix(false) * shapeTransform
        for child in shape.children {
            if let collisionInfo = self.recursiveCollidesWith(selfTransform: selfTransform, shape: child, shapeTransform: shapeChildTransform) {
                return collisionInfo
            } else {
                for sChild in self.children {
                    if let collisionInfo = sChild.recursiveCollidesWith(selfTransform: selfChildTransform, shape: child, shapeTransform: shapeChildTransform) {
                        return collisionInfo
                    }
                }
            }
        }
        
        for sChild in self.children {
            if let collisionInfo = sChild.recursiveCollidesWith(selfTransform: selfChildTransform, shape: shape, shapeTransform: shapeTransform) {
                return collisionInfo
            }
        }
        
        return nil
    }
    
    fileprivate func transform(line:LineSegment, by selfMatrix:Matrix3, and inverseMatrix:Matrix3) -> LineSegment {
        return LineSegment(first: inverseMatrix * (selfMatrix * line.firstPoint), second: inverseMatrix * (selfMatrix * line.secondPoint))
    }
    
}
