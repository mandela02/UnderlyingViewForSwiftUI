//
//  GenericManager.swift
//  Cinder
//
//  Created by TriBQ on 12/09/2022.
//

import Foundation
import UIKit

public enum GenericScrollDirection {
    case up
    case down
}

public protocol GenericSection: Identifiable, Equatable {
    var title: String { get }
    var data: [any Cell] { get set }
}

public extension GenericSection {
    var id: String {
        return UUID().uuidString
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

public protocol Cell: Identifiable, Equatable {
    
}

public extension Cell {
    var id: String {
        return UUID().uuidString
    }
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
