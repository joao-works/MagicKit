//
//  MKBrushFillStyles.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 22/11/21.
//

import SwiftUI

public enum MKBrushFillStyles: String, Codable {
    public var name: LocalizedStringKey {
        switch self {
        case .color: return "brush-style-color"
        case .gradient: return "brush-style-color"
        }
    }
    
    case color = "color"
    case gradient = "gradient"
}
