//
//  MKSmartContext.swift
//  
//
//  Created by João Gabriel Pozzobon dos Santos on 11/12/22.
//

import Foundation

public class MKSmartContext: MKContext, ObservableObject {
    public static func == (lhs: MKSmartContext, rhs: MKSmartContext) -> Bool {
        lhs.id == rhs.id
    }
    
    public var id = UUID()
    static public var type: MKContextType = .smart
    
    var currentObjectIndex: Int? = nil
    
    public init(size: CGSize) {
        self.size = size
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return MKSmartContext(size: size)
    }
    
    public func draw(from fromPoint: CGPoint,
                              to toPoint: CGPoint,
                              touchState: MKDrawingState = MKDrawingState(),
                              brush: Brush = Brush()) {
        var object = objects[safe: currentObjectIndex ?? 0]
        
        if object == nil {
            objects.append(MKObject(content: MKStrokeContent()))
            currentObjectIndex = objects.count-1
            object = objects[safe: currentObjectIndex ?? 0]
        }
        
        var content = object?.content as? MKStrokeContent ?? MKStrokeContent()
        content.brush = brush
        
        content.strokes.append(MKStroke(points: [fromPoint, toPoint],
                                        progress: touchState.progress,
                                        pressure: CGFloat(touchState.pressure)))
        
        print(content.strokes.count)
        
        object?.content = content
        
        objects[currentObjectIndex ?? 0] = object ?? objects[currentObjectIndex ?? 0]
    }
    
    public func clear() {
        
    }
    
    public func commit(brush: Brush) {
        
    }
    
    public func merge(with context: MKSmartContext, brush: Brush) {
        
    }
    
    public var size: CGSize
    @Published public var objects: [MKObject] = [MKObject(content: MKStrokeContent())]
}

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}

public struct MKObject: Identifiable, Equatable {
    public static func == (lhs: MKObject, rhs: MKObject) -> Bool {
        lhs.content.id == rhs.content.id
    }
    
    public let id = UUID()
    public var rect: CGRect = .init()
    
    public var content: any MKObjectContent
}

public protocol MKObjectContent: Identifiable, Equatable {
    var id: UUID { get }
}

public struct MKStrokeContent: MKObjectContent {
    public var id = UUID()
    
//    public var rect: CGRect {
//        var left, up, right, down: CGFloat? = nil
//
//        strokes
//            .flatMap(\.points)
//            .forEach { point in
//                if point.x < left {
//                    left = point.x
//                }
//                if point.x > right {
//                    right = point.x
//                }
//                if point.y < up {
//                    up = point.y
//                }
//                if point.y > down {
//                    down = point.y
//                }
//        }
//    }
    
    public var brush: Brush = Brush()
    public var strokes: [MKStroke] = []
    
    public func strokesInRect(rect: CGRect) -> [MKStroke] {
        return strokes.map { stroke in
            stroke.inRect(rect)
        }
    }
}

public struct MKStroke: Equatable {
    public var points: [CGPoint] = []
    
    public var progress: CGFloat
    public var pressure: CGFloat
    
    func inRect(_ rect: CGRect) -> MKStroke {
        var stroke = self
        stroke.points = points.map { point in
            return CGPoint(x: point.x*rect.width+rect.minX,
                           y: point.y*rect.height+rect.minY)
        }
        return stroke
    }
}
