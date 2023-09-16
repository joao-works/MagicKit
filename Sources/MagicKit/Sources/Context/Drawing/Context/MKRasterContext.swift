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
        self.temp = MKImage(size: image.size)
    }
    
    public init(size: CGSize) {
        self.image = MKImage(size: size)
        self.temp = MKImage(size: size)
        self.image.clear()
        self.temp.clear()
    }
    
    public var image: MKImage
    public var temp: MKImage
    
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
        let color = brush.resolveColor(for: touchState)
        let size = brush.resolveSize(for: touchState.pressure)
        
        if strokes.last == nil || strokes.last?.color != color || strokes.last?.size != size {
            if strokes.last?.points.count == 0 {
                strokes.removeLast()
            }
            
            strokes.append(Stroke(color: color, size: size))
        }
        
        if strokes.last?.points.count == 0 {
            strokes[strokes.count-1].points.append(fromPoint)
        }
        
        strokes[strokes.count-1].points.append(toPoint)
        triggerStrokes()
    }
    
    public func commit(brush: MKBrush = MKBrush(),
                       in rect: CGRect) {
        Task {
            temp.clear()
            
            for stroke in strokes {
                if stroke.points.count > 1 {
                    for i in 1..<stroke.points.count {
                        temp.draw(from: stroke.points[i-1],
                                  to: stroke.points[i],
                                  size: stroke.size,
                                  color: stroke.color)
                    }
                }
            }
            
            image.merge(with: temp, brush: brush)
            strokes.removeAll()
            trigger()
        }
    }
    
    public func merge(with context: MKRasterContext,
                      brush: MKBrush,
                      in rect: CGRect) {
        image.merge(with: context.image, brush: brush, in: rect)
        trigger()
    }
    
    public func clear() {
        image.clear()
        temp.clear()
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
