
import Foundation

extension Double {

    ///Returns the sign of this instance.
    /// - returns: 1.0 if `self` is positive, -1.0 if `self` is negative, and 0.0 is `self`  is 0.
    public func sign() -> Double {
        if self > 0.0 {
            return 1.0
        } else if self < 0.0 {
            return -1.0
        } else {
            return 0.0
        }
    }

    ///Determines if `self` is between `lower` and `upper`.  Handles both cases where `lower < upper` and `upper < lower`.
    /// - parameter lower: One of the bounds.
    /// - parameter upper: The other bound.
    /// - returns: `true` if `self` is between `lower` and `upper`.
    public func isBetween(_ lower:Double, and upper:Double) -> Bool {
        return (lower <= self && self <= upper)
            || (upper <= self && self <= lower)
    }

}
