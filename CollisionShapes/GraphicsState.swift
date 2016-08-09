//
//  GraphicsState.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 6/25/16.
//  Copyright © 2016 Cooper Knaak. All rights reserved.
//

import UIKit
import OmniSwift

public struct GraphicsState {
    
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

public protocol GraphicsStateProtocol {
    
    var graphicsState:GraphicsState { get set }
    
}

extension GraphicsStateProtocol {
    
    public var contentSize:CGSize {
        get { return self.graphicsState.contentSize }
        set { self.graphicsState.contentSize = newValue }
    }
    
    public var position:CGPoint {
        get { return self.graphicsState.position }
        set { self.graphicsState.position = newValue }
    }
    
    public var anchor:CGPoint {
        get { return self.graphicsState.anchor }
        set { self.graphicsState.anchor = newValue }
    }
    
    public var rotation:CGFloat {
        get { return self.graphicsState.rotation }
        set { self.graphicsState.rotation = newValue }
    }
    
    public var xScale:CGFloat {
        get { return self.graphicsState.xScale }
        set { self.graphicsState.xScale = newValue }
    }
    
    public var yScale:CGFloat {
        get { return self.graphicsState.yScale }
        set { self.graphicsState.yScale = newValue }
    }
    
    public var scale:CGFloat {
        get { return self.graphicsState.scale }
        set { self.graphicsState.scale = newValue }
    }
    
    public var center:CGPoint {
        get { return self.graphicsState.center }
        set { self.graphicsState.center = newValue }
    }
}

extension GLSNode {
    
    public var graphicsState:GraphicsState {
        get {
            return GraphicsState(contentSize: self.contentSize, position: self.position, anchor: self.anchor, rotation: self.rotation, xScale: self.scaleX, yScale: self.scaleY)
        }
        set {
            self.contentSize    = newValue.contentSize
            self.position       = newValue.position
            self.anchor         = newValue.anchor
            self.rotation       = newValue.rotation
            self.scaleX         = newValue.xScale
            self.scaleY         = newValue.yScale
        }
    }
    
}