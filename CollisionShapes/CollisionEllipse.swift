import UIKit
import OmniSwift

public struct CollisionEllipse: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    public var graphicsState = GraphicsState() {
        didSet {
            if !(self.graphicsState.contentSize ~= oldValue.contentSize) {
                self.regeneratePoints()
            }
        }
    }
    
    public var a:CGFloat { return self.contentSize.width / 2.0 }
    public var b:CGFloat { return self.contentSize.height / 2.0 }
    public var e:CGFloat {
        if self.a > self.b {
            return sqrt(1.0 - (self.b * self.b) / (self.a * self.a))
        } else {
            return sqrt(1.0 - (self.a * self.a) / (self.b * self.b))
        }
    }
    public var focii:[CGPoint] {
        let offset:CGPoint
        if self.a > self.b {
            offset = CGPoint(x: self.a * self.e)
        } else {
            offset = CGPoint(y: self.b * self.e)
        }
        return [self.contentSize.center + offset, self.contentSize.center - offset]
    }
    
    public var description:String { return "CollisionEllipse (\(self.center), \(self.contentSize))" }
    
    // MARK: - CollisionShape Properties
    
    public static var defaultTriangleCount = 8
    public var triangleCount = CollisionEllipse.defaultTriangleCount {
        didSet {
            self.regeneratePoints()
        }
    }
    public var children:[CollisionShape] = []
    public var boxType = CollisionBoxType.Both

    public private(set) var points:[CGPoint] = []
    
    // MARK: - Setup
    
    public init(size:CGSize) {
        self.contentSize = size
        self.regeneratePoints()
    }
    
    public init(center:CGPoint, size:CGSize) {
        self.center = center
        self.contentSize = size
        self.regeneratePoints()
    }
    
    public init(a:CGFloat, b:CGFloat) {
        self.init(size: 2.0 * CGSize(width: a, height: b))
    }
    
    public init(center:CGPoint, a:CGFloat, b:CGFloat) {
        self.init(center: center, size: 2.0 * CGSize(width: a, height: b))
    }
    
    // MARK: - Logic
    
    public func pointForAngle(angle:CGFloat) -> CGPoint {
        let cosineSquared   = cos(angle) * cos(angle)
        let sineSquared     = sin(angle) * sin(angle)
        let aSquared        = self.a * self.a
        let bSquared        = self.b * self.b
        let radius = 1.0 / sqrt(cosineSquared / aSquared + sineSquared / bSquared)
        return self.contentSize.center + CGPoint(angle: angle, length: radius)
    }
    
    public mutating func regeneratePoints() {
        self.points     = []
        for i in 0..<self.triangleCount {
            let angle = (i /% self.triangleCount) * 2.0 * CGFloat(M_PI)
            let point = self.pointForAngle(angle)
            
            self.points.append(point)
        }
        
    }
    
    // MARK: - CollisionShape Logic
    
    public func pointLiesInside(point: CGPoint) -> Bool {
        let distance = self.focii.map() { $0.distanceFrom(point) } .reduce(0.0) { $0 + $1 }
        if self.a > self.b {
            return distance <= 2.0 * self.a
        } else {
            return distance <= 2.0 * self.b
        }
    }
    
}