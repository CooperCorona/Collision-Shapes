
import CoronaMath

extension CollisionRectangle {
    
    public var bottomLeft:Point {
        get {
            return Point(x: self.center.x - self.size.width / 2.0, y: self.center.y - self.size.height / 2.0)
        }
        set {
            self.center = Point(x: newValue.x + self.size.width / 2.0, y: newValue.y + self.size.height / 2.0)
        }
    }
    
    public var bottomRight:Point {
        get {
            return Point(x: self.center.x + self.size.width / 2.0, y: self.center.y - self.size.height / 2.0)
        }
        set {
            self.center = Point(x: newValue.x - self.size.width / 2.0, y: newValue.y + self.size.height / 2.0)
        }
    }
    
    public var topRight:Point {
        get {
            return Point(x: self.center.x + self.size.width / 2.0, y: self.center.y + self.size.height / 2.0)
        }
        set {
            self.center = Point(x: newValue.x - self.size.width / 2.0, y: newValue.y - self.size.height / 2.0)
        }
    }
    
    public var topLeft:Point {
        get {
            return Point(x: self.center.x - self.size.width / 2.0, y: self.center.y + self.size.height / 2.0)
        }
        set {
            self.center = Point(x: newValue.x + self.size.width / 2.0, y: newValue.y - self.size.height / 2.0)
        }
    }
    
}
