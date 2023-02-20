//
//  Brush.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 22/11/21.
//

import SwiftUI

/// The configuration struct that styles brush strokes
public struct MKBrush: Equatable {
    public var color: MKColor
    public var gradient: MKGradient
    
    public var type: BrushTypes
    public var fillStyle: BrushFillStyles
    
    public var size: CGFloat
    
    public var sizeVariation: CGFloat
    public var sizeVariationEnabled: Bool
    
    public var opacity: CGFloat
    
    public init(color: MKColor = MKColor(color: .purple),
                gradient: MKGradient = MKGradient(colors: [MKColor(color: .purple), MKColor(color: .pink)]),
                type: BrushTypes = .pencil,
                fillStyle: BrushFillStyles = .color,
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
    
    public func variableSize(pressure: Float) -> CGFloat {
        size+(sizeVariationEnabled ? sizeVariation*CGFloat(pressure) : 0)
    }
    
    public func color(for touchState: MKDrawingState) -> Color {
        switch fillStyle {
        case .color: return color.nativeColor
        case .gradient: return gradient.point(at: touchState.progress)
        }
    }
    
    public mutating func toggleType() {
        type = type == .pencil ? .eraser : .pencil
    }
}
