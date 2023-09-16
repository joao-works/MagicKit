//
//  MKBrush.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 22/11/21.
//

import SwiftUI

/// The configuration struct that styles brush strokes
public struct MKBrush: Equatable {
    public var color: MKColor
    public var gradient: MKGradient
    
    public var type: MKBrushTypes
    public var fillStyle: MKBrushFillStyles
    
    public var size: CGFloat
    
    public var sizeVariation: CGFloat
    public var sizeVariationEnabled: Bool
    
    public var opacity: CGFloat
    
    public init(color: MKColor = MKColor(color: .purple),
                gradient: MKGradient = MKGradient(colors: [MKColor(color: .purple), MKColor(color: .pink)]),
                type: MKBrushTypes = .pencil,
                fillStyle: MKBrushFillStyles = .color,
                size: CGFloat = 10.0, sizeVariation: CGFloat = 10.0,
                sizeVariationEnabled: Bool = true,
                opacity: CGFloat = 1.0) {
        self.color = color
        self.gradient = gradient
        self.type = type
        self.fillStyle = fillStyle
        self.size = size
        self.sizeVariation = sizeVariation
        self.sizeVariationEnabled = sizeVariationEnabled
        self.opacity = opacity
    }
    
    public func resolveSize(for pressure: Float) -> CGFloat {
        size*1.5+(sizeVariationEnabled ? sizeVariation*1.5*CGFloat(pressure) : 0)
    }
    
    public func resolveColor(for touchState: MKDrawingState) -> Color {
        if type == .eraser {
            return Color.black
        }
        
        switch fillStyle {
        case .color: return color.nativeColor
        case .gradient: return gradient.color(at: touchState.progress)
        }
    }
    
    public mutating func toggleType() {
        type = type == .pencil ? .eraser : .pencil
    }
}
