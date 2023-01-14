//
//  BrushFillType.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 22/11/21.
//

import SwiftUI

public enum BrushFillStyles: String, Codable {
    public var name: LocalizedStringKey {
        switch self {
        case .color: return "brush-style-color"
        case .gradient: return "brush-style-color"
        }
    }
    
    public func bool(_ current: Binding<Self>) -> Binding<Bool> {
        .init(get: {
            return current.wrappedValue == self
        }, set: { value in
            if value {
                current.wrappedValue = self
            }
        })
    }
    
    case color = "color"
    case gradient = "gradient"
}
