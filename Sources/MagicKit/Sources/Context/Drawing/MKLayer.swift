//
//  MKLayer.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 11/12/22.
//

import Foundation

public protocol MKLayer: Identifiable, Equatable {
    var id: UUID { get }
    
    var name: String { get set }
    var hidden: Bool { get set }
}
