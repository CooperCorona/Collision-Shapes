import UIKit
import OmniSwift

public struct CollisionTriangle: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    private(set) public var points:[CGPoint] = [CGPoint.zero, CGPoint.zero, CGPoint.zero]
    public var firstPoint:CGPoint {
        get {
            return self.points[0]
        }
        set {
            self.points[0] = newValue
        }
    }
    public var secondPoint:CGPoint {
        get {
            return self.points[1]
        }
        set {
            self.points[1] = newValue
        }
    }
    public var thirdPoint:CGPoint {
        get {
            return self.points[2]
        }
        set {
            self.points[2] = newValue
        }
    }
    public var center:CGPoint {
        get {
            return self.points.reduce(CGPoint.zero) { $0 + $1 } / 3.0
        }
    }
    // MARK: - CollisionShape Properties
    
    public var frame:CGRect {
        var minX = self.firstPoint.x
        var maxX = self.firstPoint.x
        var minY = self.firstPoint.y
        var maxY = self.firstPoint.y
        for (_, point) in enumerate(self.points, range: 1..<3) {
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
        
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    public var boxType = CollisionBoxType.Both
    public var transform = Transform()
    
    public var children:[CollisionShape] = []
    
    public var description:String { return "Triangle: \(self.firstPoint), \(self.secondPoint), \(self.thirdPoint)" }
    
    // MARK: - Setup
    
    public init() {
        
    }
    
    public init(firstPoint:CGPoint, secondPoint:CGPoint, thirdPoint:CGPoint) {
        let points = [firstPoint, secondPoint, thirdPoint]
        let frame = CGRect(points: points)
        self.points = points.map() { $0 - frame.origin }
        self.transform.position = frame.origin
        self.transform.contentSize = frame.size
    }
    
    public init(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat, x3:CGFloat, y3:CGFloat) {
        self.init(firstPoint: CGPoint(x: x1, y: y1), secondPoint: CGPoint(x: x2, y: y2), thirdPoint: CGPoint(x: x3, y: y3))
    }
    
    public init?(array:[CGFloat]) {
        guard array.count >= 6 else {
            return nil
        }
        self.init(firstPoint: CGPoint(x: array[0], y: array[1]), secondPoint: CGPoint(x: array[2], y: array[3]), thirdPoint: CGPoint(x: array[4], y: array[5]))
    }
    
    // MARK: - Logic
    
    public func pointLiesInside(point:CGPoint) -> Bool {
        
        for line in LineSegment.linesBetweenPoints(self.points) {
            if line.pointLiesAbove(self.center) != line.pointLiesAbove(point) {
                return false
            }
        }
        
        return true
    }
    
}
