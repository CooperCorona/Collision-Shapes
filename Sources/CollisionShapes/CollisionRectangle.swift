
import CoronaMath

public struct CollisionRectangle: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    public var transform = Transform()
    
    // MARK: - CollisionShape Properties
    
    public var children:[CollisionShape] = []
    public var boxType = CollisionBoxType.both
    
    public var description:String { return "CollisionRectangle (\(self.position), \(self.size))" }
    
    public var points:[Point] {
        return [
            Point(x: 0.0, y: 0.0),
            Point(x: self.size.width, y: 0.0),
            Point(x: self.size.width, y: self.size.height),
            Point(x: 0.0, y: self.size.height)
        ]
    }
    
    // MARK: - Setup
    
    public init(size:Size) {
        self.transform.size = size
    }
    
    public init(center:Point, size:Size) {
        self.position       = center
        self.size    = size
    }
    
    // MARK: - Logic
    
    public func pointLiesInside(_ point: Point) -> Bool {
        return 0.0 <= point.x && point.x <= self.size.width
            && 0.0 <= point.y && point.y <= self.size.height
    }
        
}
