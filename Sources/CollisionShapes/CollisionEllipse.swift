
import Foundation
import CoronaMath

public struct CollisionEllipse: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    public var transform = Transform() {
        didSet {
            if !(self.transform.size ~= oldValue.size) {
                self.regeneratePoints()
            }
        }
    }
    
    public var a:Double { return self.size.width / 2.0 }
    public var b:Double { return self.size.height / 2.0 }
    public var e:Double {
        if self.a > self.b {
            return sqrt(1.0 - (self.b * self.b) / (self.a * self.a))
        } else {
            return sqrt(1.0 - (self.a * self.a) / (self.b * self.b))
        }
    }
    public var focii:[Point] {
        let offset:Point
        if self.a > self.b {
            offset = Point(x: self.a * self.e)
        } else {
            offset = Point(y: self.b * self.e)
        }
        return [self.size.center + offset, self.size.center - offset]
    }
    
    public var description:String { return "CollisionEllipse (\(self.center), \(self.size))" }
    
    // MARK: - CollisionShape Properties
    
    public static var defaultTriangleCount = 8
    public var triangleCount = CollisionEllipse.defaultTriangleCount {
        didSet {
            self.regeneratePoints()
        }
    }
    public var children:[CollisionShape] = []
    public var boxType = CollisionBoxType.both

    public fileprivate(set) var points:[Point] = []
    
    // MARK: - Setup
    
    public init(size:Size) {
        self.size = size
        self.regeneratePoints()
    }
    
    public init(radius:Double) {
        self.size = Size(square: 2.0 * radius)
        self.regeneratePoints()
    }
    
    public init(center:Point, size:Size) {
        self.center = center
        self.size = size
        self.regeneratePoints()
    }
    
    public init(center:Point, radius:Double) {
        self.center = center
        self.size = Size(square: 2.0 * radius)
        self.regeneratePoints()
    }
    
    public init(a:Double, b:Double) {
        self.init(size: 2.0 * Size(width: a, height: b))
    }
    
    public init(center:Point, a:Double, b:Double) {
        self.init(center: center, size: 2.0 * Size(width: a, height: b))
    }
    
    // MARK: - Logic
    
    public func pointFor(angle:Double) -> Point {
        let cosineSquared   = cos(angle) * cos(angle)
        let sineSquared     = sin(angle) * sin(angle)
        let aSquared        = self.a * self.a
        let bSquared        = self.b * self.b
        let radius = 1.0 / sqrt(cosineSquared / aSquared + sineSquared / bSquared)
        return self.size.center + Point(angle: angle, length: radius)
    }
    
    public mutating func regeneratePoints() {
        self.points = []
        for i in 0..<self.triangleCount {
            let angle = (Double(i) / Double(self.triangleCount)) * 2.0 * Double.pi
            let point = self.pointFor(angle: angle)
            
            self.points.append(point)
        }
        
    }
    
    // MARK: - CollisionShape Logic
    
    public func pointLiesInside(_ point: Point) -> Bool {
        let distance = self.focii.map() { $0.distanceFrom(vector: point) } .reduce(0.0, +)
        if self.a > self.b {
            return distance <= 2.0 * self.a
        } else {
            return distance <= 2.0 * self.b
        }
    }
    
}
