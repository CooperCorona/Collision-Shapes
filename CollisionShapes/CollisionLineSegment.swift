
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience

public struct CollisionLineSegment: CollisionShape, CustomStringConvertible {
    
    // MARK: - Propertise
    
    public var segment:LineSegment
    
    // MARK: - CollisionShape Properties
    
    public var transform = Transform()
    public var children:[CollisionShape] = []
    public var lines:[CollisionLineSegment] { return [self] }
    public var points:[CGPoint] {
        return self.segment.points
    }
    public var boxType = CollisionBoxType.both
    
    public var description:String { return "LineSegment (\(self.segment.firstPoint), \(self.segment.secondPoint))" }
    
    // MARK: - Setup
    
    public init(firstPoint:CGPoint, secondPoint:CGPoint) {
        let frame = CGRect(points: [firstPoint, secondPoint])
        self.segment = LineSegment(first: firstPoint - frame.origin, second: secondPoint - frame.origin)
        self.transform.position = frame.origin
        self.transform.contentSize = frame.size
    }
    
    public init(x1:CGFloat, y1:CGFloat, x2:CGFloat, y2:CGFloat) {
        self.init(firstPoint: CGPoint(x: x1, y: y1), secondPoint: CGPoint(x: x2, y: y2))
    }
    
    public init?(array:[CGFloat]) {
        guard array.count >= 4 else {
            return nil
        }
        
        self.init(firstPoint: CGPoint(x: array[0], y: array[1]), secondPoint: CGPoint(x: array[2], y: array[3]))
    }

    public func pointLiesInside(_ point: CGPoint) -> Bool {
        return self.segment.pointLiesInside(point)
    }
    
}
