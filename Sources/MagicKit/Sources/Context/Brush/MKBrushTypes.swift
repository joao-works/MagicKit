//
//  MKBrushTypes.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 22/11/21.
//

import SwiftUI

public enum MKBrushTypes: String, Codable {
    public var name: LocalizedStringKey {
        switch self {
        case .pencil: return "brush-type-pencil"
        case .eraser: return "brush-type-eraser"
        case .bucket: return "brush-type-bucket"
        }
    }
    
    case pencil = "pencil"
    case eraser = "eraser"
    case bucket = "bucket"
}
