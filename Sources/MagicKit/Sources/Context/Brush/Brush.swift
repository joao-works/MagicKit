//
//  Brush.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 22/11/21.
//

import SwiftUI

/// The configuration struct that styles strokes
public struct Brush: Equatable {
    public var color: BrushColor = BrushColor(color: .purple)
    public var gradient: BrushGradient = BrushGradient(colors: [])
    
    public var type: BrushTypes = .pencil
    public var fillStyle: BrushFillStyles = .gradient
    
    public var size: CGFloat = 10.0
    
    public var sizeVariation: CGFloat = 10.0
    public var sizeVariationEnabled: Bool = true
    
    public var opacity: CGFloat = 1.0
    
    public init(color: BrushColor = BrushColor(color: .purple),
                gradient: BrushGradient = BrushGradient(colors: []),
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
        case .color: return color.color
        case .gradient: return gradient.point(at: touchState.progress)
        }
    }
    
    public mutating func toggleType() {
        type = type == .pencil ? .eraser : .pencil
    }
}
