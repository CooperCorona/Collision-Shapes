//
//  GLCollisionShape.swift
//  CollisionShapes
//
//  Created by Cooper Knaak on 9/26/15.
//  Copyright © 2015 Cooper Knaak. All rights reserved.
//

import UIKit

public protocol GLCollisionShape: CollisionShape {
    
    func getPoints() -> [CGPoint]
    
}