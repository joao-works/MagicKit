//
//  DrawingImage.swift
//  DrawingImage
//
//  Created by João Gabriel Pozzobon dos Santos on 09/08/21.
//

import AppKit
import Combine

/// The core element of a drawing canvas
public class MKImage: NSImage, Identifiable, ObservableObject {
    public let id = UUID()
    
    /// The draw method draws strokes to the image through point, state and brush parameters
    public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     touchState: MKDrawingState = MKDrawingState(),
                     brush: Brush = Brush()) {
        self.lockFocus()
        
        let scale = CGAffineTransform(scaleX: size.width, y: size.height)
        
        let path = NSBezierPath()
        path.move(to: fromPoint.applying(scale))
        path.line(to: toPoint.applying(scale))
        
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = brush.variableSize(pressure: touchState.pressure)
        
        if brush.type == .pencil {
            NSColor(brush.color(for: touchState)).setStroke()
        } else {
            NSColor(.black).setStroke()
        }
        
        path.stroke()
        
        self.unlockFocus()
    }
    
    public func merge(with image: NSImage, brush: Brush) {
        self.lockFocus()
        stack(image, operation: brush.type == .pencil ? .sourceOver : .destinationOut, opacity: brush.opacity)
        self.unlockFocus()
    }
    
    public func stack(_ image: NSImage, operation: NSCompositingOperation = .sourceOver, opacity: CGFloat = 1.0) {
        image.draw(in: image.alignmentRect, from: image.alignmentRect, operation: operation, fraction: opacity)
    }
    
    public func clear() {
        self.lockFocus()
        self.alignmentRect.fill(using: .clear)
        self.unlockFocus()
    }
}
