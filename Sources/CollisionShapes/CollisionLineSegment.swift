
import CoronaMath

public struct CollisionLineSegment: CollisionShape, CustomStringConvertible {
    
    // MARK: - Propertise
    
    public var segment:LineSegment
    
    // MARK: - CollisionShape Properties
    
    public var transform = Transform()
    public var children:[CollisionShape] = []
    public var lines:[CollisionLineSegment] { return [self] }
    public var points:[Point] {
        return self.segment.points
    }
    public var boxType = CollisionBoxType.both
    
    public var description:String { return "LineSegment (\(self.segment.firstPoint), \(self.segment.secondPoint))" }
    
    // MARK: - Setup
    
    public init(firstPoint:Point, secondPoint:Point) {
        let minX = min(firstPoint.x, secondPoint.x)
        let maxX = min(firstPoint.x, secondPoint.x)
        let minY = min(firstPoint.y, secondPoint.y)
        let maxY = min(firstPoint.y, secondPoint.y)
        let frame = Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        self.segment = LineSegment(first: firstPoint - frame.origin, second: secondPoint - frame.origin)
        self.transform.position = frame.origin
        self.transform.size = frame.size
    }
    
    public init(x1:Double, y1:Double, x2:Double, y2:Double) {
        self.init(firstPoint: Point(x: x1, y: y1), secondPoint: Point(x: x2, y: y2))
    }
    
    public init?(array:[Double]) {
        guard array.count >= 4 else {
            return nil
        }
        
        self.init(firstPoint: Point(x: array[0], y: array[1]), secondPoint: Point(x: array[2], y: array[3]))
    }

    public func pointLiesInside(_ point: Point) -> Bool {
        return self.segment.pointLiesInside(point)
    }
    
}
