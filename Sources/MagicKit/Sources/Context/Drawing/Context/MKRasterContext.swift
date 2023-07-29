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
        self.localTemp = MKImage(size: Trackpad.size)
    }
    
    public init(size: CGSize) {
        self.image = MKImage(size: size)
        self.temp = MKImage(size: size)
        self.localTemp = MKImage(size: Trackpad.size)
        self.image.clear()
        self.temp.clear()
    }
    
    public var image: MKImage
    public var temp: MKImage
    public var localTemp: MKImage
    
    @Published public var id = UUID()
    @Published public var tempID = UUID()
    
    open var type: MKContextType {
        .raster
    }
    
    public var size: CGSize {
        image.size
    }
    
    public var previousPoint: CGPoint?
    
    public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     touchState: MKDrawingState = MKDrawingState(),
                     brush: MKBrush = MKBrush(),
                     local: Bool) {
        
//        var toPoint = toPoint
//        
//        if var previousPoint {
//            toPoint = CGPoint()
//            toPoint.x = previousPoint.x+(toPoint.x - previousPoint.x) * 0.3
//            toPoint.y = previousPoint.y+(toPoint.y - previousPoint.y) * 0.3
//        }
//        previousPoint = fromPoint
        
        if local {
            localTemp.draw(from: fromPoint, to: toPoint, touchState: touchState, brush: brush)
        } else {
            temp.draw(from: fromPoint, to: toPoint, touchState: touchState, brush: brush)
        }
        triggerTemp()
    }
    
    public func commit(brush: MKBrush = MKBrush(),
                       in rect: CGRect) {        
        image.merge(with: temp, brush: brush)
        image.merge(with: localTemp, brush: brush, in: rect)
        
        temp.clear()
        localTemp.clear()
        
        previousPoint = nil
        
        trigger()
        triggerTemp()
    }
    
    public func merge(with context: MKRasterContext,
                      brush: MKBrush,
                      in rect: CGRect) {
        image.merge(with: context.image, brush: brush, in: rect)
        trigger()
    }
    
    public func clear() {
        self.image.clear()
        self.temp.clear()
        trigger()
        triggerTemp()
    }
    
    public func trigger() {
        id = UUID()
    }
    
    func triggerTemp() {
        tempID = UUID()
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
