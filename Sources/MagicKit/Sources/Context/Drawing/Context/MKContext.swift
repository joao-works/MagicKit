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
    var type: MKContextType { get }
    
    func draw(from fromPoint: CGPoint,
                       to toPoint: CGPoint,
                       touchState: MKDrawingState,
                       brush: MKBrush)
    func commit(brush: MKBrush,
                in rect: CGRect)
    func clear()
    func merge(with context: Self,
               brush: MKBrush,
               in rect: CGRect)
    
    func clone() -> any MKContext
}

public enum MKContextType: Int, Codable {
    case raster = 0
    case smart = 1
    case generated = 2
}
