//
//  MKImage.swift
//  MKImage
//
//  Created by João Gabriel Pozzobon dos Santos on 09/08/21.
//

import Combine

#if os(macOS)
import AppKit

/// The core element of a drawing canvas
public class MKImage: NSImage, Identifiable, ObservableObject {
    public let id = UUID()
    
    /// The draw method draws strokes to the image through point, state and brush parameters
    public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     touchState: MKDrawingState = MKDrawingState(),
                     brush: MKBrush = MKBrush()) {
        self.lockFocus()
        
        let transform = CGAffineTransform(translationX: 0, y: size.height)
        
        let path = NSBezierPath()
        path.move(to: fromPoint.applying(transform))
        path.line(to: toPoint.applying(transform))
        
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
    
    public func merge(with image: NSImage, brush: MKBrush) {
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
#elseif os(iOS)

import UIKit

public class MKImage: UIImage, Identifiable, ObservableObject {
    public let id = UUID()
    
    convenience init(size: CGSize, filledWithColor color: UIColor = UIColor.clear, scale: CGFloat = 0.0, opaque: Bool = false) {
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        color.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image!.cgImage!)
    }
    
    
    /// The draw method draws strokes to the image through point, state and brush parameters
    public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     touchState: MKDrawingState = MKDrawingState(),
                     brush: MKBrush = MKBrush()) {
    }
    
    public func merge(with image: UIImage, brush: MKBrush) {
    }
    
//    public func stack(_ image: NSImage, operation: NSCompositingOperation = .sourceOver, opacity: CGFloat = 1.0) {
//        image.draw(in: image.alignmentRect, from: image.alignmentRect, operation: operation, fraction: opacity)
//    }
    
    public func clear() {
    }
}

#endif
