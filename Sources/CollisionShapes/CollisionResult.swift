
import CoronaMath

public struct CollisionResult {
    
    /**
     First shape associated with the collision.
     If you call ```shape.collidesWith(otherShape)```
     then ```firstShape``` referes to ```shape```.
     */
    public let firstShape:CollisionShape
    
    /**
     First shape associated with the collision.
     If you call ```shape.collidesWith(otherShape)```
     then ```secondShape``` referes to ```otherShape```.
     */
    public let secondShape:CollisionShape
    
    /**
     Returns ```firstShape``` and ```secondShape``` as a tuple.
     Designed to work with legacy code, because the collision
     detection method used to return a tuple of the two
     shapes that collided. Thus, legacy applications that aren't
     ready to upgrade can just access the shapes property and
     continue on their way.
     */
    public var shapes:(CollisionShape, CollisionShape) {
        return (self.firstShape, self.secondShape)
    }
    /**
     The point at which the shapes collided. Not a perfect
     representation, as it should really be another shape
     defining the overlap, but that would be computationally
     expensive, so this is our compromise. If the collision
     is found because a point is inside another shape,
     ```collisionPoint``` is that point. Otherwise, it's
     the point at which the line segments of the two shapes collided.
     */
    public let collisionPoint:Point
    
    internal func transform(by transform:Matrix3) -> CollisionResult {
        let collisionPoint = transform * Vector3(components: self.collisionPoint.components)
        return CollisionResult(firstShape: self.firstShape, secondShape: self.secondShape, collisionPoint: Point(components:  collisionPoint.components))
    }

    /**
     Returns a `CollisionResult` with the first and second shapes flipped.
     */
    public func flipped() -> CollisionResult {
        return CollisionResult(firstShape: self.secondShape, secondShape: self.firstShape, collisionPoint: self.collisionPoint)
    }
    
}
