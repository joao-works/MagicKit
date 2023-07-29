//
//  MKGradient.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 23/11/21.
//

import SwiftUI

public struct MKGradient: Codable, Hashable, Identifiable, Equatable {
    public var id = UUID()
    
    public init(name: String = "brush-style-gradient".localized(),
                stops: [MKGradient.Stop],
                scale: CGFloat = 125,
                style: MKGradientStyle = .interpolated) {
        self.name = name
        self.stops = stops
        self.scale = scale
        self.style = style
    }
    
    public var name = "brush-style-gradient".localized()
    public var stops: [Stop]
    public var scale: CGFloat
    public var style: MKGradientStyle
    
    public var interpolation = 0.2
    
    public var sortedStops: [Stop] {
        stops.sorted(by: { $0.location < $1.location })
    }
    
    public var nativeGradient: Gradient {
        Gradient(stops: sortedStops.map { Gradient.Stop(color: $0.color.nativeColor, location: $0.location) } )
    }
    
    public struct Stop: Codable, Hashable, Identifiable, Equatable {
        public var id = UUID()
        
        public init(color: MKColor, location: CGFloat) {
            self.color = color
            self.location = location
        }
        
        public var color: MKColor
        public var location: CGFloat
        
        func interpolate(to stop: Self, fraction: CGFloat) -> Color {
            let fraction = (fraction-location)/(stop.location-location)
            return color.nativeColor.interpolate(to: stop.color.nativeColor,
                                                 fraction: fraction)
        }
    }
    
    public func color(at fraction: CGFloat) -> Color {
        var fraction = (fraction/scale/2).truncatingRemainder(dividingBy: 2)
        
        if style == .reversible {
            fraction = fraction >= 1 ? (2-fraction) : fraction
        } else {
            fraction = fraction.truncatingRemainder(dividingBy: 1)
            if style == .interpolated {
                if fraction < interpolation/2 {
                    return sortedStops.last!.color.nativeColor.interpolate(to: sortedStops.first!.color.nativeColor,
                                                                           fraction: 0.5+fraction/interpolation)
                } else if fraction > 1-interpolation/2 {
                    return sortedStops.last!.color.nativeColor.interpolate(to: sortedStops.first!.color.nativeColor,
                                                                           fraction: (fraction-(1-interpolation/2))/interpolation)
                }
                
                fraction = (fraction-interpolation/2)/(1-interpolation)
            }
        }
        
        let start = sortedStops.last(where: { $0.location <= fraction } )
        let end = sortedStops.first(where: { $0.location > fraction } )
        
        if let start {
            if let end {
                return start.interpolate(to: end, fraction: fraction)
            }
            return start.color.nativeColor
        }
        
        return end?.color.nativeColor ?? .black
    }
        
    public func copy(name: String? = nil) -> MKGradient {
        var copy = self
        copy.id = UUID()
        if let name = name {
            copy.name = name
        }
        return copy
    }
}

extension MKGradient {
    public init(name: String = "brush-style-gradient".localized(), colors: [MKColor]) {
        let stops =  colors.enumerated()
            .map { index, color in
                Stop(color: color, location: CGFloat(index)/CGFloat(colors.count-1))
            }
        
        self.init(name: name, stops: stops)
    }
}

public enum MKGradientStyle: String, Codable, CaseIterable {
    case interpolated
    case overlaid
    case reversible
    
    public var name: String {
        return "brush-style-gradient-style-\(self)".localized()
    }
    
    public var description: String {
        return "brush-style-gradient-style-\(self)-description".localized()
    }
}
