//
//  TouchReader.swift
//  TouchReader
//
//  Created by João Gabriel Pozzobon dos Santos on 09/08/21.
//

import SwiftUI

public class TouchReader: NSView {
    public weak var delegate: TouchReaderDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        allowedTouchTypes = [.indirect]
        wantsRestingTouches = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func touchesBegan(with event: NSEvent) {
        delegate?.touchesBegan(self, touches: event.touches(matching: .touching, in: self).map(Touch.init), event: event)
    }
    
    public override func touchesMoved(with event: NSEvent) {
        delegate?.touchesMoved(self, touches: event.touches(matching: .touching, in: self).map(Touch.init), event: event)
    }

    public override func touchesEnded(with event: NSEvent) {
        delegate?.touchesEnded(self, touches: event.touches(matching: .touching, in: self).map(Touch.init), event: event)
    }
    
    public override func pressureChange(with event: NSEvent) {
        delegate?.pressureChanged(self, pressure: event.pressure, event: event)
    }
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
        
        self.normalizedX = nsTouch.normalizedPosition.x
        self.normalizedY = nsTouch.normalizedPosition.y
    }
}
