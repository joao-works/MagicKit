//
//  MKImage.swift
//  MKImage
//
//  Created by João Gabriel Pozzobon dos Santos on 09/08/21.
//

import Combine
import SwiftUI

#if os(macOS)
import AppKit

/// The core element of a drawing canvas
public class MKImage: NSImage, Identifiable, ObservableObject {
    public let id = UUID()
    
    /// The draw method draws strokes to the image through point, state and brush parameters
    public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     size: CGFloat,
                     color: Color) {
        let transform = CGAffineTransform(translationX: 0, y: self.size.height)
        
        let path = NSBezierPath()
        path.move(to: fromPoint.applying(transform))
        path.line(to: toPoint.applying(transform))
        
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.lineWidth = size
        
        NSColor(color).setStroke()
        
        path.stroke()
    }
    
    public func fill(with brush: MKBrush, touchState: MKDrawingState) {
        self.lockFocus()
        
        let rect = NSRect(origin: .zero, size: size)
        
        if brush.fillStyle == .gradient {
            if let gradient = NSGradient(colors: brush.gradient.sortedStops.map(\.color.nativeColor)
                .map { NSColor($0) } ) {
                let path = NSBezierPath(rect: rect)
                gradient.draw(in: path, angle: 270.0)
            }
        } else {
            NSColor(brush.color.nativeColor.opacity(brush.opacity)).setFill()
            rect.fill()
        }
        
        self.unlockFocus()
    }
    
    public func merge(with image: NSImage,
                      brush: MKBrush,
                      in rect: CGRect? = nil) {
        self.lockFocus()
        stack(image,
              in: rect,
              operation: brush.type == .pencil ? .sourceOver : .destinationOut,
              opacity: brush.opacity)
        self.unlockFocus()
    }
    
    public func stack(_ image: NSImage,
                      in rect: CGRect? = nil,
                      operation: NSCompositingOperation = .sourceOver,
                      opacity: CGFloat = 1.0) {
        var newRect = image.alignmentRect
        if let rect {
            newRect = .init(x: rect.minX-rect.width/2.0,
                            y: self.size.height-rect.minY-rect.height/2,
                            width: rect.width,
                            height: rect.height)
        }
        
        image.draw(in: newRect,
                   from: image.alignmentRect,
                   operation: operation,
                   fraction: opacity)
    }
    
    public func clear() {
        self.lockFocus()
        self.alignmentRect.fill(using: .clear)
        self.unlockFocus()
    }
}
#else
import UIKit

public class MKImage: UIImage, Identifiable, ObservableObject {
    public let id = UUID()
    
    public convenience init(cgImage: CGImage, size: CGSize) {
        self.init(cgImage: cgImage)
    }
    
    public convenience init(size: CGSize,
                     filledWithColor resolveColor: UIColor = UIColor.clear,
                     scale: CGFloat = 0.0,
                     opaque: Bool = false) {
        let rect = CGRectMake(0, 0, size.width, size.height)
        
        UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
        resolveColor.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.init(cgImage: image!.cgImage!)
    }
    
    public convenience init(size: CGSize,
                            from strokes: [MKRasterContext.Stroke]) async {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            for stroke in strokes {
                if stroke.points.count > 1 {
                    for i in 1..<stroke.points.count {
                        MKImage.draw(from: stroke.points[i-1],
                                     to: stroke.points[i],
                                     size: stroke.size,
                                     color: stroke.color,
                                     context: ctx.cgContext)
                    }
                }
            }
        }
         
        print(image)
        
        if let image = image.cgImage {
            self.init(cgImage: image)
        } else {
            self.init()
        }
    }
    
    static public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     size: CGFloat,
                     color: Color,
                            context: CGContext) {
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setLineWidth(size)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        var fromPoint = fromPoint
        var toPoint = toPoint
        
        fromPoint.y = -fromPoint.y
        toPoint.y = -toPoint.y
        
        context.addLines(between: [fromPoint, toPoint])
        context.drawPath(using: .stroke)
    }
    
    public func merge(with image: UIImage, brush: MKBrush, in rect: CGRect? = nil) -> MKImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            ctx.cgContext.draw(self.cgImage!, in: .init(origin: .zero, size: size))
            ctx.cgContext.draw(image.cgImage!, in: .init(origin: .zero, size: size))
        }
        
        return MKImage(cgImage: image.cgImage!)
    }
    
    public func fill(with brush: MKBrush, touchState: MKDrawingState) -> MKImage {
        lockFocus()
        
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(origin: .zero, size: size)
        
        if brush.fillStyle == .gradient {
            if let gradient = CGGradient(colorsSpace: nil,
                                         colors: brush.gradient.sortedStops.map(\.color.nativeColor)
                                            .map { $0.cgColor } as CFArray,
                                         locations: brush.gradient.sortedStops.map(\.location) as [CGFloat]) {
                let path = UIBezierPath(rect: rect)
                context.saveGState()
                path.addClip()
                context.drawLinearGradient(gradient,
                                           start: CGPoint(x: 0, y: rect.height),
                                           end: CGPoint(x: 0, y: 0),
                                           options: [])
                context.restoreGState()
            }
        } else {
            UIColor(brush.color.nativeColor.opacity(brush.opacity)).setFill()
            context.fill(rect)
        }
        
        return unlockFocus()
    }
    
    public func lockFocus() {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
    }
    
    public func unlockFocus() -> MKImage {
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        
        return MKImage(cgImage: image.cgImage!)
    }
    
    public func clear() -> MKImage {
        return MKImage(size: self.size)
    }
    
    public func stack(_ image: UIImage,
                      in rect: CGRect? = nil,
                      opacity: CGFloat = 1.0) {
    }
}
#endif
