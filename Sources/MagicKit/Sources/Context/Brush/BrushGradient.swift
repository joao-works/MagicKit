//
//  BrushGradient.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 23/11/21.
//

import SwiftUI

public struct BrushGradient: Codable, Hashable, Identifiable {
    public var id = UUID()
    
    public init(name: String = "brush-style-gradient".localized(), stops: [BrushGradient.Stop], scale: CGFloat = 500, autoReverse: Bool = true) {
        self.name = name
        self.stops = stops
        self.scale = scale
        self.autoReverse = autoReverse
    }
    
    public var name = "brush-style-gradient".localized()
    public var stops: [Stop]
    public var scale: CGFloat = 500
    public var autoReverse = true
    
    public var sortedStops: [Stop] {
        stops.sorted(by: { $0.location < $1.location })
    }
    
    public var gradient: Gradient {
        Gradient(stops: sortedStops.map( { Gradient.Stop(color: $0.color.color, location: $0.location)} ))
    }
    
    public struct Stop: Codable, Hashable, Identifiable {
        public var id = UUID()
        
        public init(color: BrushColor, location: CGFloat) {
            self.color = color
            self.location = location
        }
        
        public var color: BrushColor
        public var location: CGFloat
    }
    
    public func point(at fraction: CGFloat) -> Color {
        var fraction = fraction.truncatingRemainder(dividingBy: 2)
        fraction = autoReverse ? (fraction >= 1 ? (2-fraction) : fraction) : fraction.truncatingRemainder(dividingBy: 1)
        
        let start = sortedStops.last(where: { $0.location <= fraction } )
        let end = sortedStops.first(where: { $0.location > fraction } )
        
        if let start = start {
            if let end = end {
                let fractionInRange = (fraction-start.location)/(end.location-start.location)
                return start.color.color.interpolate(to: end.color.color, fraction: fractionInRange)
            }
            return start.color.color
        }
        
        return end?.color.color ?? .black
    }
    
    public func copy(name: String? = nil) -> BrushGradient {
        var copy = self
        copy.id = UUID()
        if let name = name {
            copy.name = name
        }
        return copy
    }
}

extension BrushGradient {
    public init(name: String = "brush-style-gradient".localized(), colors: [BrushColor]) {
        self.init(name: name, stops: colors.enumerated().map( { Stop(color: $1, location: CGFloat($0)/CGFloat(colors.count-1)) } ))
    }
}
