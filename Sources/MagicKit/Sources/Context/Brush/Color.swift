// http://brunowernimont.me/howtos/make-swiftui-color-codable

import SwiftUI

#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

fileprivate extension Color {
    #if os(macOS)
    typealias SystemColor = NSColor
    #else
    typealias SystemColor = UIColor
    #endif
    
    var colorComponents: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        #if os(macOS)
        SystemColor(self).usingColorSpace(.deviceRGB)?
            .getRed(&r, green: &g, blue: &b, alpha: &a)
        #else
        guard SystemColor(self).usingColorSpace(.deviceRGB)?
            .getRed(&r, green: &g, blue: &b, alpha: &a) else {
            // Pay attention that the color should be convertible into RGB format
            // Colors using hue, saturation and brightness won't work
            return nil
        }
        #endif
        
        return (r, g, b, a)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        
        self.init(red: r, green: g, blue: b)
    }

    public func encode(to encoder: Encoder) throws {
        guard let colorComponents = self.colorComponents else {
            return
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(colorComponents.red, forKey: .red)
        try container.encode(colorComponents.green, forKey: .green)
        try container.encode(colorComponents.blue, forKey: .blue)
    }
    
    func interpolate(to end: Self, fraction: CGFloat) -> Self {
        guard let startComponents = self.colorComponents else {
            return self
        }
        
        guard let endComponents = end.colorComponents else {
            return self
        }
        
        let red = Double((1.0-fraction)*startComponents.red+fraction*endComponents.red)
        let green = Double((1.0-fraction)*startComponents.green+fraction*endComponents.green)
        let blue = Double((1.0-fraction)*startComponents.blue+fraction*endComponents.blue)
        let alpha = Double((1.0-fraction)*startComponents.alpha+fraction*endComponents.alpha)
        
        return .init(.displayP3, red: red, green: green, blue: blue, opacity: alpha)
    }
}
