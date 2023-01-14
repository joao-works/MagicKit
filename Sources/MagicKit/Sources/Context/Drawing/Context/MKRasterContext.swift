//
//  MKRasterContext.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 19/08/21.
//

import SwiftUI

public class MKRasterContext: MKContext {
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
    
    @Published public var id = UUID()
    @Published public var tempID = UUID()
    
    static public var type: MKContextType = .raster
    
    public var size: CGSize {
        image.size
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let image = image.copy() as! MKImage
        let context = MKRasterContext(image: image)
        return context
    }
    
    public func draw(from fromPoint: CGPoint,
                     to toPoint: CGPoint,
                     touchState: MKState = MKState(),
                     brush: Brush = Brush()) {
        temp.draw(from: fromPoint, to: toPoint, touchState: touchState, brush: brush)
        triggerTemp()
    }
    
    public func commit(brush: Brush = Brush()) {
        print("COMMIT")
        image.merge(with: temp, brush: brush)
        temp.clear()
        trigger()
        triggerTemp()
    }
    
    public func merge(with context: MKRasterContext, brush: Brush) {
        image.merge(with: context.image, brush: brush)
        trigger()
    }
    
    public func clear() {
        self.image.clear()
        trigger()
    }
    
    func trigger() {
        id = UUID()
    }
    
    func triggerTemp() {
        tempID = UUID()
    }
}
