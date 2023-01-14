//
//  MKContext.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 10/12/22.
//

import Foundation

public protocol MKContext: Identifiable, Equatable, ObservableObject, NSCopying {
    var id: UUID { get set }
    var size: CGSize { get }
    static var type: MKContextType { get }
    
    func draw(from fromPoint: CGPoint,
                       to toPoint: CGPoint,
                       touchState: MKState,
                       brush: Brush)
    func commit(brush: Brush)
    func clear()
    func merge(with context: Self, brush: Brush)
}

public enum MKContextType: Int {
    case raster = 0
    case smart = 1
}
