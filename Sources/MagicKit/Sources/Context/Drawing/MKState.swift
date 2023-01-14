//
//  File.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 23/11/21.
//

import Foundation

public struct MKState {
    public init(position: CGPoint = CGPoint(),
                pressure: Float = 0,
                stage: Int = 0,
                swiped: Bool = false,
                progress: CGFloat = 0.0) {
        self.position = position
        self.pressure = pressure
        self.stage = stage
        self.swiped = swiped
        self.progress = progress
    }
    
    public var position = CGPoint()
    public var pressure: Float = 0
    public var stage = 0
    public var swiped = false
    public var progress: CGFloat = 0.0
}
