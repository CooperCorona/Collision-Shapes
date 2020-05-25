
import CoronaMath

public struct CollisionTriangle: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    fileprivate(set) public var points:[Point] = [Point.zero, Point.zero, Point.zero]
    public var firstPoint:Point {
        get {
            return self.points[0]
        }
        set {
            self.points[0] = newValue
        }
    }
    public var secondPoint:Point {
        get {
            return self.points[1]
        }
        set {
            self.points[1] = newValue
        }
    }
    public var thirdPoint:Point {
        get {
            return self.points[2]
        }
        set {
            self.points[2] = newValue
        }
    }
    public var center:Point {
        get {
            return self.points.reduce(Point.zero) { $0 + $1 } / 3.0
        }
    }
    // MARK: - CollisionShape Properties
    
    public var frame:Rect {
        var minX = self.firstPoint.x
        var maxX = self.firstPoint.x
        var minY = self.firstPoint.y
        var maxY = self.firstPoint.y
        for point in self.points[1..<3] {
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
        
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    public var boxType = CollisionBoxType.both
    public var transform = Transform()
    
    public var children:[CollisionShape] = []
    
    public var description:String { return "Triangle: \(self.firstPoint), \(self.secondPoint), \(self.thirdPoint)" }
    
    // MARK: - Setup
    
    public init() {
        
    }
    
    public init(firstPoint:Point, secondPoint:Point, thirdPoint:Point) {
        let points = [firstPoint, secondPoint, thirdPoint]
        let frame = Rect.containing(points: points)
        self.points = points.map() { $0 - frame.origin }
        self.transform.position = frame.origin
        self.transform.size = frame.size
    }
    
    public init(x1:Double, y1:Double, x2:Double, y2:Double, x3:Double, y3:Double) {
        self.init(firstPoint: Point(x: x1, y: y1), secondPoint: Point(x: x2, y: y2), thirdPoint: Point(x: x3, y: y3))
    }
    
    public init?(array:[Double]) {
        guard array.count >= 6 else {
            return nil
        }
        self.init(firstPoint: Point(x: array[0], y: array[1]), secondPoint: Point(x: array[2], y: array[3]), thirdPoint: Point(x: array[4], y: array[5]))
    }
    
    // MARK: - Logic
    
    public func pointLiesInside(_ point:Point) -> Bool {
        
        for line in LineSegment.linesBetweenPoints(self.points) {
            if line.pointLiesAbove(self.center) != line.pointLiesAbove(point) {
                return false
            }
        }
        
        return true
    }
    
}
