
import CoronaMath

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
    
    public var points:[Point] = []
    
    public var log = false
    fileprivate var axisAlignedCollisionFrame = Rect.zero
    public var collisionFrame:Rect {
        let matrix = self.transform.modelMatrix()
        let points = self.axisAlignedCollisionFrame.points.map() { matrix * $0 }
        return Rect.containing(points: points)
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
    public func pointLiesInside(_: Point) -> Bool {
        return false
    }

    fileprivate func calculateCollisionFrame() -> Rect {
        guard let firstChild = self.children.first else {
            return Rect.zero
        }
        guard var firstPoint = firstChild.points.first else {
            return Rect.zero
        }
        firstPoint = firstChild.transform.modelMatrix() * firstPoint
        var minX:Double = firstPoint.x
        var maxX:Double = firstPoint.x
        var minY:Double = firstPoint.y
        var maxY:Double = firstPoint.y
        let identity = Matrix3.identity
        for child in self.children {
            self.collisionFrame(child, matrix: identity, minX: &minX, minY: &minY, maxX: &maxX, maxY: &maxY)
        }
        if log {
            print(firstChild)
        }
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    fileprivate func collisionFrame(_ shape:CollisionShape, matrix:Matrix3, minX:inout Double, minY:inout Double, maxX:inout Double, maxY:inout Double) {
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
