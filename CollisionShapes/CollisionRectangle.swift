
#if os(iOS)
    import UIKit
#else
    import Cocoa
#endif
import CoronaConvenience

public struct CollisionRectangle: CollisionShape, CustomStringConvertible {
    
    // MARK: - Properties
    
    public var transform = Transform()
    
    // MARK: - CollisionShape Properties
    
    public var children:[CollisionShape] = []
    public var boxType = CollisionBoxType.both
    
    public var description:String { return "CollisionRectangle (\(self.position), \(self.contentSize))" }
    
    public var points:[CGPoint] {
        return [
            CGPoint(x: 0.0, y: 0.0),
            CGPoint(x: self.contentSize.width, y: 0.0),
            CGPoint(x: self.contentSize.width, y: self.contentSize.height),
            CGPoint(x: 0.0, y: self.contentSize.height)
        ]
    }
    
    // MARK: - Setup
    
    public init(size:CGSize) {
        self.transform.contentSize = size
    }
    
    public init(center:CGPoint, size:CGSize) {
        self.position       = center
        self.contentSize    = size
    }
    
    // MARK: - Logic
    
    public func pointLiesInside(_ point: CGPoint) -> Bool {
        return 0.0 <= point.x && point.x <= self.contentSize.width
            && 0.0 <= point.y && point.y <= self.contentSize.height
    }
        
}
