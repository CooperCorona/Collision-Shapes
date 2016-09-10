//
//  Transform.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 6/25/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import CoronaConvenience
import CoronaStructures

public struct Transform {
    
    public var contentSize          = CGSize.zero
    public var position             = CGPoint.zero
    public var anchor               = CGPoint(xy: 0.5)
    public var rotation:CGFloat     = 0.0
    public var xScale:CGFloat       = 1.0
    public var yScale:CGFloat       = 1.0
    public var scale:CGFloat {
        get {
            return self.xScale
        }
        set {
            self.xScale = newValue
            self.yScale = newValue
        }
    }
    public var center:CGPoint {
        get {
            return self.position - (self.anchor - 0.5) * self.contentSize
        }
        set {
            self.position = newValue + (self.anchor - 0.5) * self.contentSize
        }
    }
    
    public var frame:CGRect {
        get { return CGRect(center: self.center, size: self.contentSize) }
        set {
            self.center = newValue.center
            self.contentSize = newValue.size
        }
    }
    
    public init() {
        
    }
    
    public init(contentSize:CGSize, position:CGPoint, anchor:CGPoint, rotation:CGFloat, xScale:CGFloat, yScale:CGFloat) {
        self.contentSize = contentSize
        self.position = position
        self.anchor = anchor
        self.rotation = rotation
        self.xScale = xScale
        self.yScale = yScale
    }
    
    public func modelMatrix(renderingSelf:Bool = true) -> SCMatrix4 {
        if renderingSelf {
            return SCMatrix4(translation: self.position, rotation: self.rotation, scaleX: self.xScale, scaleY: self.yScale, anchor: self.anchor, size: self.contentSize)
        } else {
            return SCMatrix4(translation: self.position, rotation: self.rotation, scaleX: self.xScale, scaleY: self.yScale)
        }
    }//get model matrix
    
}

public protocol TransformProtocol {
    
    var transform:Transform { get set }
    
}

extension TransformProtocol {
    
    public var contentSize:CGSize {
        get { return self.transform.contentSize }
        set { self.transform.contentSize = newValue }
    }
    
    public var position:CGPoint {
        get { return self.transform.position }
        set { self.transform.position = newValue }
    }
    
    public var anchor:CGPoint {
        get { return self.transform.anchor }
        set { self.transform.anchor = newValue }
    }
    
    public var rotation:CGFloat {
        get { return self.transform.rotation }
        set { self.transform.rotation = newValue }
    }
    
    public var xScale:CGFloat {
        get { return self.transform.xScale }
        set { self.transform.xScale = newValue }
    }
    
    public var yScale:CGFloat {
        get { return self.transform.yScale }
        set { self.transform.yScale = newValue }
    }
    
    public var scale:CGFloat {
        get { return self.transform.scale }
        set { self.transform.scale = newValue }
    }
    
    public var center:CGPoint {
        get { return self.transform.center }
        set { self.transform.center = newValue }
    }
}
