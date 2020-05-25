
import CoronaMath

/**
 Defines a lightweight implementation of a line segment
 that is independant of any parent's space.
 */
public struct LineSegment {
    
    // MARK: - Properties
    
    public var firstPoint = Point.zero
    public var secondPoint = Point.zero
    public var isVertical:Bool {
        return self.firstPoint.x ~= self.secondPoint.x
    }
    public var slope:Double? {
        if self.isVertical {
            return nil
        } else {
            return (self.secondPoint.y - self.firstPoint.y) / (self.secondPoint.x - self.firstPoint.x)
        }
    }
    public var yIntercept:Double? {
        if let slope = self.slope {
            return (self.firstPoint.y - slope * self.firstPoint.x)
        }
        
        return nil
    }
    public var vector:Point {
        return (self.secondPoint - self.firstPoint).unit()
    }
    public var normal:Point {
        let vector = self.vector
        return Point(x: vector.y, y: -vector.x)
    }
    public var length:Double {
        return self.firstPoint.distanceFrom(vector: self.secondPoint)
    }
    
    public var points:[Point] {
        return [self.firstPoint, self.secondPoint]
    }
    
    public var frame:Rect {
        let minX = min(self.firstPoint.x, self.secondPoint.x)
        let minY = min(self.firstPoint.y, self.secondPoint.y)
        let maxX = max(self.firstPoint.x, self.secondPoint.x)
        let maxY = max(self.firstPoint.y, self.secondPoint.y)
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    // MARK: - Setup
    
    public init(first:Point, second:Point) {
        self.firstPoint = first
        self.secondPoint = second
    }
    
    public static func linesBetweenPoints(_ points:[Point]) -> [LineSegment] {
        var lines:[LineSegment] = []
        for (i, p) in points.enumerated().dropLast() {
            lines.append(LineSegment(first: p, second: points[i + 1]))
        }
        if let first = points.first, let last = points.last , !(first ~= last) {
            lines.append(LineSegment(first: last, second: first))
        }
        return lines
    }
    
    // MARK: - Logic
    
    public func yAtX(_ x:Double) -> Double? {
        guard let slope = self.slope, let yIntercept = self.yIntercept else {
            return nil
        }
        return slope * x + yIntercept
    }
    
    public func pointAtX(_ x:Double) -> Point? {
        guard let y = self.yAtX(x) else {
            return nil
        }
        return Point(x: x, y: y)
    }
    
    public func pointLiesAbove(_ point:Point) -> Bool {
        if let slope = self.slope, let yIntercept = self.yIntercept {
            return point.y - slope * point.x > yIntercept
        } else {
            return point.x > self.firstPoint.x
        }
    }
    
    // MARK: - Collision
    
    public static func value(_ value:Double, isInBetween lower:Double, and higher:Double) -> Bool {
        return (lower <= value && value <= higher) || (higher <= value && value <= lower)
    }
    
    /**
     Determines if two line segments collide. Instead of returning
     a boolean, collidesWith returns the collision point because
     the CollisionShape collidesWith method needs it. Thus, it
     uses nil to test for no collision.
     - parameter line: Another line to determine collision with.
     - returns: The collision point of the two lines, or nil if the lines don't collide.
     */
    public func collidesWith(_ line:LineSegment) -> Point? {
        
        if self.isVertical && line.isVertical {
            guard self.firstPoint.x ~= line.firstPoint.x else {
                return nil
            }
            if LineSegment.value(line.firstPoint.y, isInBetween: self.firstPoint.y, and: self.secondPoint.y) {
                let firstMid  = (line.firstPoint.y + self.firstPoint.y) / 2.0
                let secondMid = (line.firstPoint.y + self.secondPoint.y) / 2.0
                if LineSegment.value(firstMid, isInBetween: line.firstPoint.y, and: line.secondPoint.y) {
                    return Point(x: self.firstPoint.x, y: firstMid)
                } else {
                    return Point(x: self.firstPoint.y, y: secondMid)
                }
            } else if LineSegment.value(line.secondPoint.y, isInBetween: self.firstPoint.y, and: self.secondPoint.y) {
                let firstMid  = (line.secondPoint.y + self.firstPoint.y) / 2.0
                let secondMid = (line.secondPoint.y + self.secondPoint.y) / 2.0
                if LineSegment.value(firstMid, isInBetween: line.firstPoint.y, and: line.secondPoint.y) {
                    return Point(x: self.firstPoint.x, y: firstMid)
                } else {
                    return Point(x: self.firstPoint.y, y: secondMid)
                }
            } else {
                return nil
            }
        } else if self.isVertical {
            if let point = line.pointAtX(self.firstPoint.x) {
                if line.pointLiesAbove(self.firstPoint) != line.pointLiesAbove(self.secondPoint) && line.frame.contains(point: point) {
                    return point
                }
            }
            return nil
        } else if line.isVertical {
            // This causes 'self' and 'line' to get flipped,
            // causing the previous if statement to get executed.
            return line.collidesWith(self)
        }
        
        
        guard let slope1 = self.slope, let yIntercept1 = self.yIntercept, let slope2 = line.slope, let yIntercept2 = line.yIntercept , !(slope1 ~= slope2) else {
            return nil
        }
        
        let x = (yIntercept1 - yIntercept2) / (slope2 - slope1)
        guard let point = self.pointAtX(x) else {
            return nil
        }
        
        if self.frame.contains(point: point) && line.frame.contains(point: point) {
            return point
        } else {
            return nil
        }
    }
    
    public func pointLiesInside(_ point: Point) -> Bool {
        
        guard self.frame.contains(point: point) else {
            return false
        }
        guard let selfPoint = self.pointAtX(point.x) else {
            return false
        }
        
        return selfPoint ~= point
    }
    
}
