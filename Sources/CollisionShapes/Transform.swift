
import CoronaMath

public struct Transform {
    
    public var size          = Size.zero
    public var position             = Point.zero
    public var anchor               = Point(xy: 0.5)
    public var rotation:Double     = 0.0
    public var scale                = Point(xy: 1.0)
    public var center:Point {
        get {
            return self.position - (self.anchor - 0.5) * Point(components: self.size.components)
        }
        set {
            self.position = newValue + (self.anchor - 0.5) * Point(components: self.size.components)
        }
    }
    
    public var frame:Rect {
        get { return Rect(center: self.center, size: self.size) }
        set {
            self.center = newValue.center
            self.size = newValue.size
        }
    }
    
    public init() {
        
    }
    
    public init(position:Point, scale:Point, rotation:Double, anchor:Point, size:Size) {
        self.size = size
        self.position = position
        self.anchor = anchor
        self.rotation = rotation
    }
    
    public func modelMatrix(_ renderingSelf:Bool = true) -> Matrix3 {
        if renderingSelf {
            return Matrix3(translation: self.position, scale: self.scale, rotation: self.rotation, anchor: self.anchor, size: self.size)
        } else {
            return Matrix3(translation: self.position, scale: self.scale, rotation: self.rotation)
        }
    }//get model matrix
    
}

public protocol Transformable {
    
    var transform:Transform { get set }
    
}

extension Transformable {
    
    public var position:Point {
        get { return self.transform.position }
        set { self.transform.position = newValue }
    }

    public var scale:Point {
        get { return self.transform.scale }
        set { self.transform.scale = newValue }
    }

    public var rotation:Double {
        get { return self.transform.rotation }
        set { self.transform.rotation = newValue }
    }
    
    public var anchor:Point {
        get { return self.transform.anchor }
        set { self.transform.anchor = newValue }
    }

    public var size:Size {
        get { return self.transform.size }
        set { self.transform.size = newValue }
    }
    
    public var center:Point {
        get { return self.transform.center }
        set { self.transform.center = newValue }
    }
}
