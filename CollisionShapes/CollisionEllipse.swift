import UIKit
import OmniSwift

public struct CollisionEllipse: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    public var size:CGSize = CGSize.zero {
        didSet {
            self.regenerateLines()
        }
    }
    
    public var a:CGFloat { return self.size.width / 2.0 }
    public var b:CGFloat { return self.size.height / 2.0 }
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
        return [self.realCenter + offset, self.realCenter - offset]
    }
    
    public var description:String { return "CollisionEllipse (\(self.center), \(self.size))" }
    
    // MARK: - CollisionShape Properties
    
    public static var defaultTriangleCount = 8
    public var triangleCount = CollisionEllipse.defaultTriangleCount {
        didSet {
            self.regenerateLines()
        }
    }
    private var triangles:[CollisionShape] = []
    private var internalChildren:[CollisionShape] = []
    public var children:[CollisionShape] {
        get {
            return /*self.triangles + */self.internalChildren
        }
        set {
            self.internalChildren = newValue
        }
    }
    
    public var center:CGPoint = CGPoint.zero {
        didSet {
            for iii in self.children.range {
                self.children[iii].setCenterOfParentRecursively(self.center)
            }
            
            let delta = self.center - oldValue
            for iii in self.lines.range {
                self.lines[iii].translate(delta)
            }
            
            for iii in self.points.range {
                self.points[iii] += delta
            }
        }
    }
    public var frame:CGRect {
        return CGRect(center: self.center, size: self.size)
    }
    public var boxType = CollisionBoxType.HitBox
    public var centerOfParent = CGPoint.zero {
        didSet {
            
            let delta = self.centerOfParent - oldValue
            for iii in self.lines.range {
                self.lines[iii].translate(delta)
            }
            
            for iii in self.points.range {
                self.points[iii] += delta
            }
        }
    }
    
    public private(set) var points:[CGPoint] = []
    public private(set) var lines:[CollisionLineSegment] = []
    
    // MARK: - Setup
    
    public init() {
        self.regenerateLines()
    }
    
    public init(size:CGSize) {
        self.size = size
        self.regenerateLines()
    }
    
    public init(center:CGPoint, size:CGSize) {
        self.center = center
        self.size = size
        self.regenerateLines()
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
        return self.center + CGPoint(angle: angle, length: radius)
    }
    
    public mutating func regenerateLines() {
        
        self.lines      = []
        self.points     = []
        for iii in 0..<self.triangleCount {
            let angle = (iii /% self.triangleCount) * 2.0 * CGFloat(M_PI)
            let nextAngle = ((iii + 1) /% self.triangleCount) * 2.0 * CGFloat(M_PI)
            let point = self.pointForAngle(angle)
            let nextPoint = self.pointForAngle(nextAngle)
            
            var line = CollisionLineSegment(firstPoint: point, secondPoint: nextPoint)
            line.translate(self.centerOfParent)
            self.lines.append(line)
            self.points.append(point + self.centerOfParent)
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
    
    public mutating func translate(translation: CGPoint) {
        self.center += translation
    }
    
    public mutating func flipHorizontallyAbout(x: CGFloat) {
        
        self.flip(&self.center.x, about: x)
        
        for iii in self.children.range {
            self.children[iii].flipHorizontallyAbout(0.0)
        }
        
    }
    
    public mutating func flipVerticallyAbout(y: CGFloat) {
        
        self.flip(&self.center.y, about: y)
        
        for iii in self.children.range {
            self.children[iii].flipVerticallyAbout(0.0)
        }
    }
    
}