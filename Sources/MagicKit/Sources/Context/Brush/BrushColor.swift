//
//  BrushColor.swift
//  Magic
//
//  Created by João Gabriel Pozzobon dos Santos on 22/11/21.
//

import SwiftUI

public struct BrushColor: Codable, Equatable, Hashable, Identifiable {
    public var id: String {
        self.name
    }
    
    public init(name: String = "brush-style-color".localized(), color: Color) {
        self.name = name
        self.color = color
    }
    
    public var name: String
    public var color: Color
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

public extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "")
    }
    
    func localized(with arguments: [CVarArg]) -> String {
        return String(format: self.localized(), arguments: arguments)
    }
}
