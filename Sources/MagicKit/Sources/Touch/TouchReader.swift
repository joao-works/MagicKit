//
//  TouchReader.swift
//  TouchReader
//
//  Created by João Gabriel Pozzobon dos Santos on 09/08/21.
//

import SwiftUI

#if !os(macOS)
public typealias NSEvent = UIEvent
public typealias NSTouch = UITouch
public typealias NSView = UIView
#endif

public class TouchReader: NSView {
    public weak var delegate: TouchReaderDelegate?
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        
        #if os(macOS)
        allowedTouchTypes = [.indirect]
        wantsRestingTouches = true
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(macOS)
    public override func touchesBegan(with event: NSEvent) {
        #if os(macOS)
        delegate?.touchesBegan(self, touches: event.touches(matching: .touching, in: self).map(Touch.init), event: event)
        #endif
    }
    
    public override func touchesMoved(with event: NSEvent) {
        #if os(macOS)
        delegate?.touchesMoved(self, touches: event.touches(matching: .touching, in: self).map(Touch.init), event: event)
        #endif
    }

    public override func touchesEnded(with event: NSEvent) {
        #if os(macOS)
        delegate?.touchesEnded(self, touches: event.touches(matching: .touching, in: self).map(Touch.init), event: event)
        #endif
    }
    
    public override func pressureChange(with event: NSEvent) {
        #if os(macOS)
        delegate?.pressureChanged(self, pressure: event.pressure, event: event)
        #endif
    }
    #endif
}

/// The delegate to a ``TouchReader`` view
public protocol TouchReaderDelegate: AnyObject {
    func touchesBegan(_ view: TouchReader, touches: [Touch], event: NSEvent)
    func touchesMoved(_ view: TouchReader, touches: [Touch], event: NSEvent)
    func touchesEnded(_ view: TouchReader, touches: [Touch], event: NSEvent)
    func pressureChanged(_ view: TouchReader, pressure: Float, event: NSEvent)
}

public struct Touch: Identifiable, Equatable {
    public let id: Int
    
    let normalizedX: CGFloat
    let normalizedY: CGFloat
    
    public var point: CGPoint {
        CGPoint(x: normalizedX, y: normalizedY)
    }

    init(_ nsTouch: NSTouch) {
        self.id = nsTouch.hash
        
        #if os(macOS)
        self.normalizedX = nsTouch.normalizedPosition.x
        self.normalizedY = nsTouch.normalizedPosition.y
        #else
        self.normalizedX = 0
        self.normalizedY = 0
        #endif
    }
}
