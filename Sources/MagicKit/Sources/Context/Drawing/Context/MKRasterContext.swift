//
//  MKRasterContext.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 19/08/21.
//

import SwiftUI

public struct Trackpad {
    public static var size: CGSize = CGSize(width: 742, height: 452)
}

open class MKRasterContext: MKContext {
    public static func == (lhs: MKRasterContext, rhs: MKRasterContext) -> Bool {
        lhs.id == rhs.id
    }
    
    public init(image: MKImage) {
        self.image = image
    }
    
    public init(size: CGSize) {
        self.image = MKImage(size: size)
        self.image.clear()
    }
    
    public var image: MKImage
    
    @Published public var strokes = [Stroke()]
    
    public struct Stroke {
        public var points: [CGPoint] = []
        public var color: Color = .purple
        public var size: CGFloat = 10
    }
    
    @Published public var id = UUID()
    @Published public var strokesID = UUID()
    
    open var type: MKContextType {
        .raster
    }
    
    public var size: CGSize {
        image.size
    }
    
    public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     touchState: MKDrawingState = MKDrawingState(),
                     brush: MKBrush = MKBrush()) {
        if brush.type == .bucket {
            image.fill(with: brush, touchState: touchState)
            strokes.removeAll()
            trigger()
        } else {
            let color = brush.resolveColor(for: touchState)
            let size = brush.resolveSize(for: touchState.pressure)
            
            if strokes.last == nil || strokes.last?.color != color || strokes.last?.size != size {
                if strokes.last?.points.count == 0 {
                    strokes.removeLast()
                }
                
                strokes.append(Stroke(color: color, size: size))
            }
            
            let lastPoint = strokes.last?.points.last
            
            if strokes.last?.points.count == 0 {
                strokes[strokes.count-1].points.append(fromPoint)
            }
            
            var point = toPoint
            if let lastPoint {
                point = CGPoint(x: (fromPoint.x + lastPoint.x)/2,
                                y: (fromPoint.y + lastPoint.y)/2)
            }
            
            strokes[strokes.count-1].points.append(point)
            triggerStrokes()
        }
    }
    
    public func commit(brush: MKBrush = MKBrush(),
                       in rect: CGRect) {
        Task {
            #if os(macOS)
            await temp.lockFocus()
            for stroke in strokes {
                if stroke.points.count > 1 {
                    for i in 1..<stroke.points.count {
                        await temp.draw(from: stroke.points[i-1],
                                  to: stroke.points[i],
                                  size: stroke.size,
                                  color: stroke.color)
                    }
                }
            }

            await temp.unlockFocus()
            await image.merge(with: temp, brush: brush)
            #else
            let temp = await MKImage(size: image.size, from: strokes)
            await image = image.merge(with: temp, brush: brush)
            #endif
       
            strokes.removeAll()
            trigger()
        }
    }
    
    public func merge(with context: MKRasterContext,
                      brush: MKBrush,
                      in rect: CGRect) {
        #if os(macOS)
        image.merge(with: context.image, brush: brush, in: rect)
        #else
        image = image.merge(with: context.image, brush: brush, in: rect)
        #endif
        trigger()
    }
    
    public func clear() {
        Task {
            #if os(macOS)
            await image.clear()
            #else
            image = await image.clear()
            #endif
        }
        
        strokes.removeAll()
        trigger()
        triggerStrokes()
    }
    
    public func trigger() {
        id = UUID()
    }
    
    func triggerStrokes() {
        strokesID = UUID()
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let image = image.copy() as! MKImage
        let context = MKRasterContext(image: image)
        return context
    }
    
    public func clone() -> any MKContext {
        if let context = copy() as? MKRasterContext {
            return context
        }
        return self
    }
}
